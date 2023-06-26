// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {

    constructor () ERC721("Badge", "B") {}

    struct Goal {
        address studentsAccount;
        string subjects;
        string detailGoal;
        uint startDate;
        uint endDate;
        string proveUrl;
    }

    // 선생님인지 확인
    mapping(address => bool) public isTeacher;
    // 토큰아이디를 발행해준 선생님
    mapping(uint => address) public teachers;
    // 발행 완료가 됐는지
    mapping(uint => bool) public isAchieved;
    //토큰아이디의 메타데이터
    mapping(uint => string) public metadataUris;
    
    // 학생의 목표들
    mapping(address => Goal[]) public studentsGoals;
    // 학생이 서류 제출한 토큰 아이디들
    uint[] submmitedGoals;

    // 초기 목표 설정(어떤 과목, 세부 목표, 시작일, 종료일, 달성여부, 선생님 승인여부, 민팅 승인여부) - 학생이 실행
    function setGoal(string memory _subject, string memory _detail, uint _start, uint _end) public {
        require(bytes(_detail).length > 0 && _start > 0 && _end > 0, "input value");

        studentsGoals[msg.sender].push(Goal(msg.sender, _subject, _detail, _start, _end, ""));
    }

    function getStudentsGoals(address _studentAddress) public view returns(Goal[] memory) {
        return studentsGoals[_studentAddress];
    }

    // 목표 달성에 대한 자료 제출
    function submitEvidence(address _teacher, uint _contentsNumber, string memory _url) public {
        uint tokenId = totalSupply() + 1;
        
        require(isTeacher[_teacher], "This address owner is not a Teacher");
        require(bytes(_url).length > 0, "input value");

        studentsGoals[msg.sender][_contentsNumber - 1].proveUrl = _url;
        teachers[tokenId] = _teacher;
    }

    // 메타데이터 보기
    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return metadataUris[_tokenId];
    }

    // 선생님 설정
    function setTeacher(address _teacher) public onlyOwner {
        isTeacher[_teacher] = !isTeacher[_teacher];
    }

    // 토큰 아이디가 발행이 됐는지 확인을 해야함
    function mintNFT(address _studentAddress, uint _tokenId, string memory _metadataUri) public {
        require(msg.sender == teachers[_tokenId], "msg.sender is not my teacher");
        require(bytes(_metadataUri).length > 0, "input vlaue");
        
        metadataUris[_tokenId] = _metadataUri;
        _mint(_studentAddress, _tokenId);
        isAchieved[_tokenId] = true;
    }

    function renounceOwnership() public override onlyOwner {}

    function transferOwnership(address newOwner) public override {}

    function _transfer(address from, address to, uint tokenId) internal override{}
}