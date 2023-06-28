// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721Enumerable, Ownable {
    string public before_URI;
    string public after_URI;

    constructor (string memory b_uri, string memory a_uri) ERC721("Badge", "B") {
        before_URI = b_uri;
        after_URI = a_uri;
    }

    struct Goal {
        address studentsAccount;
        uint startDate;
        uint endDate;
        string proveUrl;
    }

    // 선생님 여부 확인
    mapping(address => bool) public isTeacher;
    // 토큰아이디 발행 담당 선생님
    mapping(uint => address) public teachers;
    // 목표 달성 여부
    mapping(uint => bool) public isAchieved;
    // 증빙서류 제출 여부
    mapping(uint => bool) public isSubmmited;
    //토큰아이디의 메타데이터
    mapping(uint => string) public metadataUris;
    // 학생의 목표
    mapping(uint => Goal) public goals;

    // 선생님 설정
    function setTeacher(address _teacher) public onlyOwner {
        isTeacher[_teacher] = !isTeacher[_teacher];
    }

    // 민팅 및 초기 목표 설정
    function mintAndSetGoal(address _teacher, uint64 _start, uint64 _end) public {
        uint tokenId = totalSupply() + 1;

        require(isTeacher[_teacher], "Account owner is not a teacher");

        _mint(msg.sender, tokenId);
        metadataUris[tokenId] = string(abi.encodePacked(before_URI, "/", Strings.toString(tokenId), ".json"));
        teachers[tokenId] = _teacher;
        goals[tokenId] = Goal(msg.sender, _start, _end, "");
    }

    // 토큰 정보 보기 ??
    function getGoalByIndex(uint _tokenId) public view returns(Goal memory) {
        return goals[_tokenId];
    }

    // 본인의 전체 목표 조회
    function getMyGoals() public view returns(Goal[] memory) {
        uint nftLength = balanceOf(msg.sender);
        uint[] memory allNfts = new uint[](nftLength);

        for(uint i=0; i<nftLength; i++) {
            allNfts[i] = tokenOfOwnerByIndex(msg.sender, i);
        }

        Goal[] memory myGoals = new Goal[](nftLength);

        for(uint j=0; j<nftLength; j++) {
            myGoals[j] = goals[allNfts[j]];
        }

        return myGoals;
    }

    // 목표 달성에 대한 자료 제출
    function submitEvidence(uint _tokenId, string memory _url) public {
        require(msg.sender == ownerOf(_tokenId), "Not your goal");
        require(bytes(_url).length > 0, "input value");

        goals[_tokenId].proveUrl = _url;
        isSubmmited[_tokenId] = true;
    }

    // 선생님이 확인 후 메타데이터 변경
    function changeMetadataUri(uint _tokenId) public {
        require(msg.sender == teachers[_tokenId], "Msg.sender is not my teacher");
        require(_tokenId <= totalSupply(), "Not minted yet");
        require(isSubmmited[_tokenId], "Not submmited evidence yet");

        metadataUris[_tokenId] = string(abi.encodePacked(after_URI, "/", Strings.toString(_tokenId), ".json"));
        isAchieved[_tokenId] = true;
    }

    // 메타데이터 보기
    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return metadataUris[_tokenId];
    }

    function renounceOwnership() public override onlyOwner {}

    function transferOwnership(address newOwner) public override {}

    function _transfer(address from, address to, uint tokenId) internal override{}
}