// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract cheemsCoin{ 
        int balance = 0;

        // constructor() public{ 
        //     balance = 0; 
        // }
        function getBalance() view public returns(int){ 
            return balance; 

        }
        function deposit(int amt)public{ 
            balance = balance+amt;
        }
        function withdraw(int amt)public{ 
            balance = balance-amt;
        }
        

}
