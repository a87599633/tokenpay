// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract  presale{


    //usdt代币合约地址
    address public usdttoken=0x8b5b1A58f67bD69e46E4E0F48A8B9BEF4f94B0a0;
   
   //axs代币合约地址
    address public axstoken=0x43a3ADa420846079b6507f328eD2309BEDe54201;
  
    address public ownerAddress;
    //代币单价 1usdt=>100axs  
    uint256 public presalePrice=0.01*10**18;

    //买多少代币
   // uint256 public presaleToken=0;

     
     //购买代币余额查询
    mapping(address => uint) public _balances;
    
     constructor ()public{        
        ownerAddress=msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == ownerAddress,"isn't owner");
        _;   
    }

    // 收到bnb 转给发送地址axs代币  注意代币的精度转化计算
    // function receiveBNB() public payable{
    //     IERC20(axstoken).transfer(msg.sender,msg.value*100);        
    // }



// 块号
//     function getBlockNum() public view returns(uint256){
//         return block.number;
//     }

// //合约地址中的代币余额
    function getContractBanlance()public view returns(uint256){
        uint256 bal=IERC20(usdttoken).balanceOf(address(this));
        return bal;
    }


// //用户地址的中的代币余额
    //   function getUserBanlance(address userAddress)public view returns(uint256){
    //  //   require(block.timestamp>=1657378982,"over");
    //     uint256 bal=IERC20(0x43a3ADa420846079b6507f328eD2309BEDe54201).balanceOf(userAddress);
    //     return bal;
    // }
   

  //预售   时间戳成功
    function preasle(uint256 paynum)public{
        uint256 time=block.timestamp;
        require(time>=1657525732&&time<=1657825999,"over");
        uint256  buynum=paynum/presalePrice*10**18;
         
        IERC20(usdttoken).transferFrom(msg.sender,address(this),paynum);
           
        _balances[msg.sender] += buynum;
    }
      



//预售结束后转入的usdt转出到指定地址
    function withdraw() public onlyOwner{
        uint256 time=block.timestamp;
        require(time>1657825999,"over");
        uint256 amount=IERC20(usdttoken).balanceOf(address(this));       
        IERC20(usdttoken).transfer(0x529Aa0dB82defd69Af731220C5A7b34d72E48c9F,amount);
    }




//取出代币
    function recaptionAXS(uint256 amount)public{
        uint256 time=block.timestamp;
        require(time>1657825999,"over");
       require(_balances[msg.sender] >= amount,"over");
        _balances[msg.sender] -= amount;
        IERC20(axstoken).transfer(msg.sender,amount);            
    }
  

}


