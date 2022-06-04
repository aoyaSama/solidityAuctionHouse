// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TicTacToe {
    // game configuration
    address[2] _playerAddress; // address of both players
    uint32 _turnLength; // max time for each turn

    // nonce material used to pick the first player
    bytes32 _p1Commitment;
    uint8 _p2Nonce;

    // game state
    uint8[9] _board; // serialized 3x3 array
    uint8 _currentPlayer; // 0 or 1, indicating whose turn it is
    uint256 _turnDeadline; // deadline for submitting next move

    // Create a new game , challenging a named opponent .
    // The value passed in is the stake which the opponent must match .
    // The challenger commits to its nonce used to determine first mover .
    constructor(
        address opponent,
        uint32 turnLength,
        bytes32 p1Commitment
    ) public {
        _playerAddress[0] = msg.sender;
        _playerAddress[1] = opponent;
        _turnLength = turnLength;
        _p1Commitment = p1Commitment;
    }

    // Join a game as the second player .
    function joinGame(uint8 p2Nonce) public payable {
        // only the specified opponent may join
        if (msg.sender != _playerAddress[1]) revert();
        // must match player 1’s stake .
        require(msg.value >= address(this).balance);
        _p2Nonce = p2Nonce;
    }

    // Revealing player 1’s nonce to choose who goes first .
    function startGame(uint8 p1Nonce) public {
        // must open the original commitment
        require(keccak256(abi.encodePacked(p1Nonce)) == _p1Commitment);
        // XOR both nonces and take the last bit to pick the first player
        _currentPlayer = (p1Nonce ^ _p2Nonce) & 0x01;

        // start the clock for the next move
        _turnDeadline = block.number + _turnLength;
    }

    // Submit a move
    function playMove(uint8 squareToPlay) public payable {
        // make sure correct player is submitting a move
        require(msg.sender != _playerAddress[_currentPlayer]);

        // claim this square for the current player .
        _board[squareToPlay] = _currentPlayer;

        // If the game is won , send the pot to the winner
        if (false) selfdestruct(payable(msg.sender));

        // Flip the current player
        _currentPlayer ^= 0x1;

        // start the clock for the next move
        _turnDeadline = block.number + _turnLength;
    }

    // Default the game if a player takes too long to submit a move
    function defaultGame() public payable {
        if (block.number > _turnDeadline) selfdestruct(payable(msg.sender));
    }
}
