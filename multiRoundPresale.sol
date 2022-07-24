// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract  multiplePresales{

    address public usdtToken; //=0x8b5b1A58f67bD69e46E4E0F48A8B9BEF4f94B0a0;
    address public axsToken;  //=0x43a3ADa420846079b6507f328eD2309BEDe54201;
    address public ownerAddress;
    uint256 public presalePrice;  //=0.01*10**18;     //代币单价 1usdt=>100axs  
    uint256 public starTime;
    uint256 public endTime;
    uint256 public price;
    uint256 public maxPayUsdt=100*10**18;   //最大购买金额100usdt
    uint256 public userwithDrawTime; //用户取款时间    
    address private withdrawAddress; //项目方取usdt地址；
    mapping(address => uint) public _balances;
    mapping(address => uint) public userBuyTotleUsdt;  //用户累计购买多少usdt；
    mapping(address => address) public parents; // 记录上级  我的地址 => 我的上级地址
    address[10] public parentAddr;

    address public firstAddress; // 合约发布第一邀请人
    modifier onlyOwner{
        require(msg.sender == ownerAddress,"isn't owner");
        _;   
    }
    //每轮预售信息  开始与结束时间及价格
    struct PresaleInfo{
        uint256 starTime;
        uint256 endTime;
        uint256 price;
    }

    PresaleInfo[] public presaleInfos;

    constructor(address _axsToken,address _usdtToken,uint256 _userwithDrawTime,address _withdrawAddress)  {
        ownerAddress=msg.sender;
        usdtToken=_usdtToken;
        axsToken=_axsToken;        
        userwithDrawTime = _userwithDrawTime;
        withdrawAddress = _withdrawAddress;
        ownerAddress=msg.sender;
        firstAddress = msg.sender;// 初始化第一个用户地址，发布前改成自己项目用的地址
    }

    //设置项目方取款地址
    function setWithdrawlAdderss(address _withdrawAddress)public  onlyOwner{
        withdrawAddress=_withdrawAddress;
    }


//设置预售轮次信息
    function createPresaleInfo(PresaleInfo memory presaleInfo)public onlyOwner{
        presaleInfos.push(presaleInfo);
        //PresaleInfo memory presaleInfo = PresaleInfo(starTime,endTime,presalePrice);
    }



// //合约地址中的代币余额
    function getContractBanlance()public view returns(uint256){
        uint256 bal=IERC20(usdtToken).balanceOf(address(this));
        return bal;
    }

   //如果时间出现不合理 可及时调整时间
    function getuserwithDrawTime(uint256 _time)public onlyOwner{
        userwithDrawTime=_time;
    }


// //用户地址的中的代币余额
    //   function getUserBanlance(address userAddress)public view returns(uint256){
    //  //   require(block.timestamp>=1657378982,"over");
    //     uint256 bal=IERC20(0x43a3ADa420846079b6507f328eD2309BEDe54201).balanceOf(userAddress);
    //     return bal;
    // }

   // 绑定上级
    function addRecord(address parentAddress) public returns(bool){
        require(parentAddress != address(0),"Parent address 0 is not allowed"); // 不允许上级地址为0地址
        require(parentAddress != msg.sender, "You are not allowed to invite yourself");// 不允许自己的上级是自己
        // 验证要绑定的上级是否有上级，只有有上级的用户，才能被绑定为上级
        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, "no");
        // 判断是否已经绑定过上级
        if(parents[msg.sender] != address(0)){
            // 已有上级，返回一个true
            return true;
        }
        parents[msg.sender] = parentAddress;

    }
 
//获取上10级地址 进行分红
   function getParents() public view returns(address[10] memory myParents){
       address parentAddress=parents[msg.sender];
       for(uint8 i=0;i<10;i++){
            if(parentAddress==address(0)){
                 break;
             }
            myParents[i]=parentAddress;
            parentAddress = parents[parentAddress];

       }
       myParents;
   } 

  //预售   购买额度不能超过最大可购买金额  每轮<=100u   
    function presale(uint256 round,uint256 payAmount)public returns(bool){
       PresaleInfo memory presaleInfo=presaleInfos[round];                                 //参与预售轮次
        parentAddr=getParents();
       require(block.timestamp >=presaleInfo.starTime,"Presale has not started");         //检测预售是否开始
       require(block.timestamp <= presaleInfo.endTime,"Presale is over");                  //检测预售是否结束
        require(payAmount <= maxPayUsdt,"Exceeding the available amount");                  //检测是否超过可买金额
        userBuyTotleUsdt[msg.sender] += payAmount;
       require (userBuyTotleUsdt[msg.sender] <= presaleInfos.length*maxPayUsdt,"over");
        if (userBuyTotleUsdt[msg.sender] <= presaleInfos.length*maxPayUsdt){
            IERC20(usdtToken).transferFrom(msg.sender,address(this),payAmount); 
            presalePrice=price;//*10**18;
            uint256  getTokenNum = payAmount*10**18/presalePrice;
            _balances[msg.sender] += getTokenNum;
            for(uint8 i=0;i<10; i++){
                address dividendAddr=parentAddr[i];
                if(dividendAddr==address(0)){
                    break;
                }
                if(i==0){
                    _balances[dividendAddr] += getTokenNum*1/20;
                } 
                else if(i==1){
                    _balances[dividendAddr] += getTokenNum*3/100;
                }
                else if(i==2){
                    _balances[dividendAddr] += getTokenNum*2/100;
                }
                else if(i==3){
                    _balances[dividendAddr] += getTokenNum*2/1000;
                }
                else if(i==4){
                    _balances[dividendAddr] += getTokenNum*1/1000;
                }
                else {
                    _balances[dividendAddr] += getTokenNum*5/1000;
                }             
            }
        }
        else {
            userBuyTotleUsdt[msg.sender] -= payAmount;
           // return false;
        }

    }
      



//多轮预售结束后项目方取出转入的usdt转出到指定地址
    function withdraw() public onlyOwner{
        require(block.timestamp>userwithDrawTime,"over");
        uint256 amount=IERC20(usdtToken).balanceOf(address(this));       
        IERC20(usdtToken).transfer(withdrawAddress,amount);
    }




//多轮预售结束后用户取出axs代币
    function recaptionAXS()public{
        require(block.timestamp>userwithDrawTime,"over");
        //require(_balances[msg.sender] >= amount,"over");
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender]=0;
        IERC20(axsToken).transfer(msg.sender,amount);            
    }
  

}


