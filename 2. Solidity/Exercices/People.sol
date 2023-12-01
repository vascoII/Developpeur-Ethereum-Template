// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract People {
    struct Person {
        string name;
        uint256 age;
    }
    
    Person public moi;
    Person[] public personArray;

    function modifyPerson(string memory _name, uint256 _age) public {
        moi = Person(_name, _age);
    }

    function addPerson(string memory _name, uint256 _age) public {
        personArray.push(Person(_name, _age));
    }

    function removePerson() public {
        personArray.pop();
    }

    function removePerson(string memory _name, uint256 _age) public {
        uint arrayLength = personArray.length;
        for (uint i = 0; i < arrayLength; i++) {
            if (keccak256(bytes(personArray[i].name)) == keccak256(bytes(_name)) && personArray[i].age == _age) {
                for (uint j = i; j < arrayLength - 1; j++) {
                    personArray[j] = personArray[j + 1];
                }    
                personArray.pop();
                break;
            }
        }
    }

}
