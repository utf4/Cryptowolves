// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract WorldOfPanda is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, ERC721Royalty {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;
    
    // BLACKPANDAURI URI
    string private _blackPandaURI;


    address private admin;
    address private contractAddress;

    bool private lengendaryPandaMinted; // Check to mint legendary panda once

    string private lengendaryURI ; // URI for legendary panda

    uint256 public maxSupply; // max NFT can be minted
    
    uint256 public _mintPrice; // initail price to mint NFT

    uint256 public _whitelist_mintPrice; // initail price to mint NFT


    uint256 private royalty;  
    uint256 private NFTshowtime;  
    uint256[] private mintedNFT ; // List of NFT ids minted
    uint256 private preSaleTime; 
    uint256 private actualSale; 


    mapping (bytes32 => bool ) private NFT_hashes ; // checks URI uniqueness
    mapping (uint256 => pandaStruct) public pandaList ; // List of NFT data, pass tokenID of NFT as @param
    mapping (address => bool ) private isWhiteList; // List of whitelisted addresses
    mapping (address => uint256 ) private addressMintCount ; // Count of NFTs minted by address
    mapping (address => uint256 ) private batchMintCalled ; // Count of batchMint func called by whitelisted address
    mapping (uint256 => string) private _tokenURIs;   // To save the actual token URIs
 


    struct pandaStruct {
        uint256 id;
        string uri;
        uint price;
        address owner;
        uint256 mintTime;
        bool preSale;
        bool forSale;
    }



    event TokenMinted( uint256 indexed tokenId, address owner);
    event priceSetEvent ( uint ID , bool price_is_set );
    event payment_Sent(bool payment_Sent);

    

     modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }


     constructor(
         string memory _contractName, 
         string memory _contractSymbol, 
         uint256 _nftMintPrice, 
         uint256 _whiteListPrice, 
         uint96 _royality 
        ) ERC721(_contractName,_contractSymbol)
     {
         contractAddress = address(this) ;
         _mintPrice = _nftMintPrice;
         _whitelist_mintPrice = _whiteListPrice;
         royalty = _royality;
         lengendaryPandaMinted = false;
         maxSupply = 8008;
         _blackPandaURI = "https://dweb.link/ipfs/bafybeidke67gy7db4zwt7umvu2wyjcyawo232q5gc2yp2lj6td7dzxxh5a/mystry.json";         NFTshowtime = 1644284526;
         lengendaryURI = "https://dweb.link/ipfs/bafybeifjflpjd26lyt7n3ysyijx4jefhz2mpffo5tyugcdfemabzidr55u/Zeus-01legendary.json" ;

         setAdmin( owner() );
         addWhiteList ( msg.sender );
         _setDefaultRoyalty(msg.sender, _royality);
         preSaleTime = 1644935323;
         actualSale = 1645280923;

     }


    function setPresaleTime( uint256 time ) public onlyAdmin  {
        preSaleTime = time;
    }

    function setActualSaleTime (uint256 time) public onlyAdmin {
        actualSale = time;
    }

    function getContractBalance() public view returns( uint256 ){
        return address(this).balance;
    }
    
    function setAdmin (address _admin) public onlyOwner {
        admin = _admin;
    }

    function getAdmin ()  public view onlyOwner returns (address) {
       return admin ;
    }

    function getRoyaltyValue ( ) public view onlyAdmin returns (uint256) {
        return royalty;
    }

    function setNFTshow ( uint256 time ) public onlyAdmin  {
        NFTshowtime = time;
    }


    function getMintedList() public view returns (uint256[] memory minted_nft_ids ){
        return mintedNFT;
    }

    
    function addWhiteList(address id) public onlyAdmin {
        isWhiteList[id] = true ;
    }

    function removeWhiteList(address id) public onlyAdmin {
        isWhiteList[id] = false ;
    }

    function sendContractBalance(address _to) public onlyAdmin {
        (bool sent,) = _to.call{value: address(this).balance }("");
        require(sent == true, "Payment unsuccessful");
        emit payment_Sent(sent);
    }


    function safeMint ( address to, string memory tokenUri) private returns (uint256) 
    {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), tokenUri); // BLACKPANDAURI
        _tokenURIs[_tokenIdCounter.current()] = tokenUri;
        emit TokenMinted(_tokenIdCounter.current(), to); 
        return _tokenIdCounter.current();
    }

    function setTokenURI(uint256 tokenId, string memory tokenUri) internal onlyAdmin { 
        require(_exists(tokenId) == true, "ID does not exist" );
        _setTokenURI(tokenId, tokenUri);
    }

    
  
    function batchMint( string[] memory tokenUriList) public payable returns (uint256 [] memory )
    {
        require(block.timestamp >= preSaleTime, "Pre Sale is not started yet.");  ///check if pre sale is started
        require ( tokenUriList.length <= 10 , "Can not mint for than 10 NFTs" ) ;
        uint256 mintPrice = _mintPrice ;

        if ( isWhiteList[ msg.sender ] == true){
            mintPrice = _whitelist_mintPrice;
            
            if (block.timestamp <= actualSale) { /// check if actual sale is started
                batchMintCalled[msg.sender] += 1 ;
                require( batchMintCalled[msg.sender] <=2 , "WhiteListed already used batchMint 2 times and it is still PreSale Period") ; 
            }
        }

        if ( isWhiteList[ msg.sender ] == false)
        {
            // check if actual sale is started
            require ( block.timestamp >= actualSale , "PreSale is ON, non-white-list cannot mint");
        }

        
        uint256[] memory tokenIds = new uint256[](tokenUriList.length);

        require( msg.value >= mintPrice*tokenUriList.length , "Sent less than price") ; 
        require(tokenUriList.length <= maxSupply -  _tokenIdCounter.current() ,"Cant mint more than Supply Left");

        for (uint256 i = 0; i < tokenUriList.length; i++) 
        {
            require(UniqueSVG_by_Hash(bytes(tokenUriList[i])) == true, "NFT not unique"); 
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;

            uint256 tokenId = safeMint( msg.sender, tokenUriList[i] );
            mintedNFT.push(tokenId);
            tokenIds[i] = tokenId;

            pandaList[tokenId].id = tokenId;
            pandaList[tokenId].price = mintPrice;
            pandaList[tokenId].uri = tokenUriList[i];
            pandaList[tokenId].owner = msg.sender;
            pandaList[tokenId].mintTime = block.timestamp;

        }
        uint256 to_send_royalty = msg.value;

        (bool sent,) = admin.call{value: to_send_royalty}("");
        require(sent == true, "Payment to Admin unsuccessful");
        emit payment_Sent(sent);

        addressMintCount[msg.sender] += tokenUriList.length ;

        if (lengendaryPandaMinted == false) {
            if (addressMintCount[msg.sender] >= 6000 ){
                legendaryMint ( msg.sender ) ;
                lengendaryPandaMinted = true;
            }
        }
        return tokenIds;
    }

    function legendaryMint (address _sender ) private {

        require(UniqueSVG_by_Hash(bytes(lengendaryURI)) == true, "NFT not unique"); 
        NFT_hashes[keccak256(bytes(lengendaryURI))] = true;

        uint256 tokenId = safeMint( msg.sender, lengendaryURI );
        mintedNFT.push(tokenId);

        pandaList[tokenId].id = tokenId;
        pandaList[tokenId].price = _mintPrice;
        pandaList[tokenId].uri = lengendaryURI;
        pandaList[tokenId].owner = _sender;
        pandaList[tokenId].mintTime = block.timestamp;
        addressMintCount[_sender] += 1 ;

    }




    function safeTransferFrom( address _from, address _to, uint256 _id ) virtual override public {
            super.safeTransferFrom( _from  , _to , _id );
    }

    function transferFrom( address _from, address _to, uint256 _id ) virtual override public {
            super.transferFrom( _from  , _to , _id );
    }





    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC721Royalty)
    {
        require(msg.sender == ownerOf(tokenId));
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        if (block.timestamp >= NFTshowtime){
            return super.tokenURI(tokenId);
        } else{
        return _blackPandaURI;
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721, ERC721Royalty) returns (bool) 
    {
        return super.supportsInterface(interfaceId);
    }


     /*  
    * checks if NFT tokenURI to be added is unique or not 
    *
    * @param _tokenURI  -- URI to be checked for uniqueness
    */
    function UniqueSVG_by_Hash(bytes memory _tokenURI ) private view returns (bool) {
        
        if (NFT_hashes[keccak256(_tokenURI)] == true){
            return false;
        }else{
            return true;
        }
   }


}
