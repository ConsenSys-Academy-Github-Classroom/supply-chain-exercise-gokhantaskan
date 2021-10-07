// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>
  address public owner;

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) public items;

  // <enum State: ForSale, Sold, Shipped, Received>
  enum State { ForSale, Sold, Shipped, Received }

  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event LogForSale(uint _skuCount);

  // <LogSold event: sku arg>
  event LogSold(uint sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint sku);

  // <LogReceived event: sku arg>


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
  modifier isOwner (address _address) { 
    require (msg.sender == _address, "You are not the owner!");
    _;
  }

  modifier onlySeller (uint sku) {
    require(msg.sender == items[sku].seller, "You are not the seller!");
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address, "You are not the caller!"); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "You don't have enough money!"); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;

    // address payable buyer = address(uint160(items[_sku].buyer)); // ! Payable convertion to get rid of the error
    // address payable buyer = payable(items[_sku].buyer); // ! Payable convertion to get rid of the error

    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(uint _sku) {
    require(
      items[_sku].state == State.ForSale &&
      items[_sku].price > 0,
      "It is not for sale!"
    );
    _;
  }

  modifier sold(uint _sku) {
     require(items[_sku].state == State.Sold, "It is not sold yet!");
    _;
  }

  modifier shipped(uint _sku) {
     require(items[_sku].state == State.Shipped, "It is not shipped yet!");
    _;
  }

  modifier received(uint _sku) {
     require(items[_sku].state == State.Received, "It is not received yet!");
    _;
  }

  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary? Answer, No.
    skuCount = 0;
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true

    items[skuCount] = Item({
     name: _name, 
     price: _price, 
     sku: skuCount, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0) 
    });
    
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // // 6. call the event associated with this function!
  function buyItem(uint sku) public payable {
    address payable seller = items[sku].seller;
    uint price = items[sku].price;

    items[sku].buyer = msg.sender;
    items[sku].state = State.Sold;
    seller.transfer(price);

    emit LogSold(sku);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public onlySeller(sku) {
    items[sku].state = State.Shipped;

    emit LogShipped(sku);
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public {
    items[sku].state = State.Received;
  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view 
    returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}
