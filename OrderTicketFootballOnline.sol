//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

contract OrderTicketFootballOnline{

    //definisikan variable
    mapping(address => Viewer) mappingViewer;
    mapping(string => uint) ticketPrice;
    mapping(string => int) ticketAvailable;

    event logNontonBola(Viewer viewer);
    enum TicketType {VIP, Executive, Regular}
    Viewer ticketOrder;

    uint indexVip=1;
    uint indexExecutive=1;
    uint indexRegular=1;
    address payable owner;

    //define View struct
    struct Viewer {
        TicketType ticketType;
        string ticketNumber;
        bool buyTicket;
    }

    //define default value
    constructor() {
        //jumlah tiket yang tersedia
        ticketAvailable["vip"] = 5;
        ticketAvailable["executive"] = 5;
        ticketAvailable["regular"] = 5;

        //harga tiket masing masing kelas
        ticketPrice["vip"] = 3 ether;
        ticketPrice["executive"] = 2 ether;
        ticketPrice["regular"] = 1 ether;
    }

    //validation the ticket has been purchased?
    modifier checkTicketisPurchased(){
        require(mappingViewer[msg.sender].buyTicket == false, "Sorry, this account has already purchased ticket.");
        _;
    }

    modifier checkTicketPayment(TicketType _ticketType){
         if(_ticketType == TicketType.VIP){
            require(msg.value >= ticketPrice["vip"], "Sorry, you don't have enough money to buy VIP ticket");
            ticketOrder.ticketNumber = string(abi.encodePacked("TVIP_", integerToString(indexVip++)));
            ticketOrder.ticketType = TicketType.VIP;
            ticketAvailable["vip"]--;
        } else if(_ticketType == TicketType.Executive){
            require(msg.value >= ticketPrice["executive"], "Sorry, you don't have enough money to buy Executive ticket");
            ticketOrder.ticketNumber = string(abi.encodePacked("TEXE_", integerToString(indexExecutive++)));
            ticketOrder.ticketType = TicketType.Executive;
            ticketAvailable["executive"]--;
            
        } else if(_ticketType == TicketType.Regular){
            require(msg.value >= ticketPrice["regular"], "Sorry, you don't have enough money to buy Regular ticket");
            ticketOrder.ticketNumber = string(abi.encodePacked("TREG_", integerToString(indexRegular++)));
            ticketOrder.ticketType = TicketType.Regular;
            ticketAvailable["regular"]--;
        }
        _;
    }

    modifier checkAvailabilityTicket(TicketType ticket) {
        if(ticket == TicketType.VIP){
            require(ticketAvailable["vip"] > 0, "Sorry, VIP class tickets are sold out");
        } else if(ticket == TicketType.Executive){
            require(ticketAvailable["executive"] > 0, "Sorry, Executive class tickets are sold out");
        } else if(ticket == TicketType.Regular){
            require(ticketAvailable["regular"] > 0, "Sorry, Regular class tickets are sold out");
        }
        _;
    }

    //process buy ticket
    function buyTicket(TicketType _ticket) payable external checkAvailabilityTicket(_ticket) checkTicketPayment(_ticket) checkTicketisPurchased{
        owner = msg.sender;
        owner.transfer(msg.value);
        ticketOrder.buyTicket = true;
        mappingViewer[owner] = ticketOrder;
        emit logNontonBola(ticketOrder);
    }

    //ticket info
    function getTicket(address _address) public view returns(Viewer memory _viewer){
        return mappingViewer[_address];
    }

    //check remaining tickets for Executive tickets
    function remainingExecutiveTicket() public view returns(int sisa){
        return ticketAvailable["executive"];
    }

    //check remaining tickets for VIP tickets
    function remainingVIPTicket() public view returns(int sisa){
        return ticketAvailable["vip"];
    }

    //check remaining tickets for Regular tickets
    function remainingRegularTicket() public view returns(int sisa){
        return ticketAvailable["regular"];
    }

    //========================= utilisasi tambahan ===============================
    //convert dari integer ke String
    function integerToString(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
      return string(bstr);
   }
}