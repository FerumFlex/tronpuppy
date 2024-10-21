import asyncio

from tronpy import AsyncTron, keys

from deploy import deploy_contract, create_provider, settings


async def main():
    provider = await create_provider()
    priv_key = keys.PrivateKey(bytes.fromhex(settings.tron_private_key))
    public_address = priv_key.public_key.to_base58check_address()

    async with AsyncTron(provider) as client:
        puppy_contract_file = "TronPuppy.sol/TronPuppy"
        tron_puppy_address = await deploy_contract(puppy_contract_file)

        miner_contract_file = "Miner.sol/Miner"
        miner_puppy_address = await deploy_contract(miner_contract_file)

        puppy_contract = await client.get_contract(tron_puppy_address)
        txb = await puppy_contract.functions.setMinter(miner_puppy_address)
        txb = txb.with_owner(public_address).fee_limit(2000_000_000)
        txn = await txb.build()
        txn_ret = await txn.sign(priv_key).broadcast()
        txn_id = txn_ret["txid"]
        print(f"Executed transaction to set minter {txn_id}")

        miner_contract = await client.get_contract(miner_puppy_address)
        txb = await miner_contract.functions.setToken(tron_puppy_address)
        txb = txb.with_owner(public_address).fee_limit(2000_000_000)
        txn = await txb.build()
        txn_ret = await txn.sign(priv_key).broadcast()
        txn_id = txn_ret["txid"]
        print(f"Executed transaction to set token {txn_id}")

    print(f"TronPuppy address: {tron_puppy_address}")
    print(f"Miner address: {miner_puppy_address}")


asyncio.run(main())