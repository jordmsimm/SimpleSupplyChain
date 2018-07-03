pragma solidity ^0.4.23;

contract SupplyChain {

  address owner;
  uint skuCount;
  
  mapping (uint => Item) public items;
  enum State {ForSale,Sold,Shipped,Recieved}
  struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
}
    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);
  modifier onlyOwner (){require(msg.sender == owner); _;}
  modifier verifyCaller(address _address) { require (msg.sender == _address); _;}
  modifier paidEnough(uint _price) { require(msg.value >= _price); _;}
  modifier checkValue(uint _sku) {
      require(msg.value > items[_sku].price);//refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }
  modifier forSale(uint _sku) { require(items[_sku].state == State.ForSale); _; }
  modifier sold(uint _sku) { require(items[_sku].state == State.Sold); _; }
  modifier shipped(uint _sku) { require(items[_sku].state == State.Shipped); _; }
  modifier received(uint _sku) { require(items[_sku].state == State.Recieved); _; }


  constructor() public {
      skuCount = 0;
      owner = msg.sender;
   
  }

  function addItem(string _name, uint _price) public {
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
    skuCount = skuCount + 1;
  }

  
  function buyItem(uint _sku) 
    public payable forSale(_sku) paidEnough(items[_sku].price) checkValue(_sku)
  {
      items[_sku].seller.transfer(items[_sku].price);
      items[_sku].buyer = msg.sender;
      items[_sku].state = State.Sold;
      emit Sold(_sku);
      
  }

  function shipItem(uint sku)
    public sold(sku) verifyCaller(items[sku].seller)
  {
      items[sku].state = State.Shipped;
      emit Shipped(sku);
      
  }

  function receiveItem(uint sku)
    public shipped(sku) verifyCaller(items[sku].buyer)
  {
      items[sku].state = State.Recieved;
      emit Received(sku);
  }

  function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}
