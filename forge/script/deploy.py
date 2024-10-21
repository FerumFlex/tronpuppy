import sys
import json
import asyncio
import pathlib

from pydantic_settings import BaseSettings
from pydantic import Field

from tronpy import AsyncTron, keys
from tronpy.async_contract import AsyncContract
from tronpy.providers.async_http import AsyncHTTPProvider

BASE_DIR = pathlib.Path(__file__).parent.parent
BUILD_DIR = BASE_DIR / "out"
ARTIFACTS_DIR = BASE_DIR / "artifacts"


class Settings(BaseSettings):
    tron_node_url: str = Field(env="tron_node_url", default=None)
    tron_node_api_key: str = Field(env="tron_node_api_key", default=None)
    tron_private_key: str = Field(env="tron_private_key", default=None)


settings = Settings()


def load_abi(name: str) -> dict:
    with open(BUILD_DIR / f"{name}.json", mode="r") as f:
        return json.load(f)


async def create_provider() -> AsyncHTTPProvider:
    provider = AsyncHTTPProvider(
        endpoint_uri=settings.tron_node_url,
        api_key=settings.tron_node_api_key,
    )
    return provider


async def gef_contract_addres(client: AsyncTron, txid: str) -> str:
    info = await client.get_transaction_info(txn_id=txid)
    assert info["receipt"]["result"] == "SUCCESS"
    return info["contract_address"]



async def deploy_contract(filename: str, params: list[any] = None) -> str:
    print(f"Deploying {filename}")

    provider = await create_provider()
    info = load_abi(filename)

    priv_key = keys.PrivateKey(bytes.fromhex(settings.tron_private_key))
    public_address = priv_key.public_key.to_base58check_address()

    bytecode = info["bytecode"]["object"].removeprefix("0x")

    async with AsyncTron(provider) as client:
        contract = AsyncContract(
            bytecode=bytecode,
            abi=info["abi"],
            user_resource_percent=100,
            origin_address=info.get("origin_address", ""),
            code_hash=info.get("code_hash", ""),
            client=client,
        )
        if params:
            parameters = contract.constructor.encode_parameter(*params)
            contract.bytecode = contract.bytecode + parameters

        txb = client.trx.deploy_contract(public_address, contract)
        txb = txb.with_owner(public_address).fee_limit(2000_000_000)
        txn = await txb.build()
        txn_ret = await txn.sign(priv_key).broadcast()
        txn_id = txn_ret["txid"]
        print(f"Executed transaction {txn_id}")

        print("Waiting...")
        await asyncio.sleep(10)

        contract_address = await gef_contract_addres(client, txn_id)
        print(f"Smart contract address {contract_address}")
        json_data = {
            "address": contract_address,
            "abi": info["abi"],
            "bytecode": bytecode,
        }
        outname = pathlib.Path(filename).name
        with open(ARTIFACTS_DIR / f"{outname}.json", mode="w") as f:
            f.write(json.dumps(json_data))

        return contract_address


async def main() -> None:
    filename = sys.argv[1]
    await deploy_contract(filename)


if __name__ == "__main__":
    asyncio.run(main())
