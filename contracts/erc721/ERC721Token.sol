pragma solidity ^0.4.23;

import "./ERC721BasicToken.sol";
import "evolutionerc721/contracts/ERC721Enumerable.sol";
import "evolutionerc721/contracts/ERC721Metadata.sol";


contract ERC721Token is ERC721BasicToken,ERC721Enumerable, ERC721Metadata{

    bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
    /**
     * 0x780e9d63 ===
     *   bytes4(keccak256('totalSupply()')) ^
     *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *   bytes4(keccak256('tokenByIndex(uint256)'))
     */

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *   bytes4(keccak256('name()')) ^
     *   bytes4(keccak256('symbol()')) ^
     *   bytes4(keccak256('tokenURI(uint256)'))
     */
    // Token name
    string internal name_;

    // Token symbol
    string internal symbol_;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal allTokensIndex;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;


    constructor(string _name, string _symbol) public {
        name_ = _name;
        symbol_ = _symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(InterfaceId_ERC721Enumerable);
        _registerInterface(InterfaceId_ERC721Metadata);
    }

    function name() external view returns (string) {
        return name_;
    }

    function symbol() external view returns (string) {
        return symbol_;
    }

    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return tokenURIs[_tokenId];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return allTokens[_index];
    }

    function _setTokenURI(uint256 _tokenId, string _uri) internal {
        require(exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }

    function addTokenTo(address _to, uint256 _tokenId) internal {
        super.addTokenTo(_to, _tokenId);
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }


    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        super.removeTokenFrom(_from, _tokenId);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }


    function _mint(address _to, uint256 _tokenId) internal {
        super._mint(_to, _tokenId);

        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
    }


    function _burn(address _owner, uint256 _tokenId) internal {
        super._burn(_owner, _tokenId);

        // Clear metadata (if any)
        if (bytes(tokenURIs[_tokenId]).length != 0) {
            delete tokenURIs[_tokenId];
        }

        // Reorg all tokens array
        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];

        allTokens[tokenIndex] = lastToken;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        allTokensIndex[_tokenId] = 0;
        allTokensIndex[lastToken] = tokenIndex;
    }



}


