pragma solidity ^0.4.23;

import "evolutionerc721/contracts/ERC721TokenReceiver.sol";


contract ERC721Receiver is ERC721TokenReceiver{

    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {
        return this.onERC721Received.selector;
    }
}
