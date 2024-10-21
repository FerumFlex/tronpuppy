// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 12976306518566816974018360515595390761084674321361665701001844506757019808836;
    uint256 constant alphay  = 21384108751756830206142236285494775794760336920112567243348939190916606618939;
    uint256 constant betax1  = 4631434702444154190559191253152372079334229232744735559352660895356417431867;
    uint256 constant betax2  = 12551417482369141524434779862603042250340668999993362423323778140782202356174;
    uint256 constant betay1  = 19277250889044298645949125572798451235574939263641944455103998776462078561709;
    uint256 constant betay2  = 18032365835803470753923058673202561481697568211237597170818580035992596330268;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 17477556965885007784087958826569433041011110052894019858981702882962520641227;
    uint256 constant deltax2 = 8318603408221082753227597288149686146431786669958770135390686563191643798403;
    uint256 constant deltay1 = 14826024810872695444720004665947701969326995416034424344769445178154486728500;
    uint256 constant deltay2 = 9471813311018476865077648343536313454697897306378752887488290287479420613975;

    
    uint256 constant IC0x = 21526524538327876486872522187066904676435933432402098613666362846540891283431;
    uint256 constant IC0y = 21231841256276631321694565425906163616414741983921679528730807547648170388414;
    
    uint256 constant IC1x = 6402866587712193364795844107719554763634157181467288427319622239378532708528;
    uint256 constant IC1y = 9981012327429619598697518398327992462186921515614370773764498020678928041026;
    
    uint256 constant IC2x = 21466784981075131339210525420867367178602990688633647768869154651307370198578;
    uint256 constant IC2y = 10095846851016461430812502284933758160104112420312578338366075422199592184141;
    
    uint256 constant IC3x = 3265715811696150988960441940929466287466372215902736589667532976305748629989;
    uint256 constant IC3y = 11125471372413710088361469165279887562711777292396248202865136720749122696218;
    
    uint256 constant IC4x = 12749782014935606146776003138729915062030631403373022839972408979175286983144;
    uint256 constant IC4y = 20396865793335041471402758223957604420540475480060114888726127256631858363164;
    
    uint256 constant IC5x = 601652289072704166230221129390311930491892970709154226053041896635843811295;
    uint256 constant IC5y = 18636451574379548332226099264929963161220022587238623942147873816360446605872;
    
    uint256 constant IC6x = 5311961060096496769319794272780948476206603184992991479732988102563064582838;
    uint256 constant IC6y = 14941371232853948184717276484200564934992942377944859506167754958437071872923;
    
    uint256 constant IC7x = 1131103510048973280226041582461793349870603322585201036044567731981681994691;
    uint256 constant IC7y = 473527218594575790796699021774165165614727749029960835592774059789326870850;
    
    uint256 constant IC8x = 18516516603179260179660631505689211750797636444701607388981720862241771805856;
    uint256 constant IC8y = 18373003900254336214063006278827803889506611524544721270565082007664099241261;
    
    uint256 constant IC9x = 11273219953769613176116102790166949002609369934960777956654298811961015763978;
    uint256 constant IC9y = 2019184985437603260405530504175004808394339515629699821652228836473074757794;
    
    uint256 constant IC10x = 9364837908000227587537886849564201961086019337722593231830813864658556767553;
    uint256 constant IC10y = 5609790438945095425129825066111842758622379376196883552696149565063807928055;
    
    uint256 constant IC11x = 19046901085757399605474603510089130899706734972461455977957157916119500992132;
    uint256 constant IC11y = 17520750310817094583831305674470838993008428448410501694181464924215406883433;
    
    uint256 constant IC12x = 7636963821444209455479802566595309538807860759738484854643566636165719079757;
    uint256 constant IC12y = 8237853121854915636616007088304294509310531919342145803797255937413029628698;
    
    uint256 constant IC13x = 12018720617357958960105568409689857306103543112260667178439352230247691558207;
    uint256 constant IC13y = 9764018548547182643427937937585951497046022688340455281136539268542592495609;
    
    uint256 constant IC14x = 11353087363383512859868786085110035225213825473902215619470657433523553414267;
    uint256 constant IC14y = 10164438999839026339144497278214633494762578158809851233775140359126167969782;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[14] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
