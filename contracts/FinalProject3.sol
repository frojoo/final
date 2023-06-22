// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/*
- 학생이 본인의 학생부 기록의 목표를 입력해서 달성하면 ERC-721을 활용해 소울바운드토큰을 발행해주는 기능을 만드려고한다.
- 메타마스크 로그인
    로그인을 하면 메타마스크 주소에 따라 선생님과 학생이 구분된다.
    1. 학생은 목표 구조체 안에 따로 넣어져서 학생임을 구분할 수 있고, 선생님은 따로 설정하던가 아니면 다르게 설정
    2. 학생의 주소를 모두 안다고 가정하고 (백엔드?) 선생님의 주소만 확정할지
- 목표 선정 인풋 : 어떤 과목, 세부 목표, 시작일, 종료일, 달성여부, 선생님 승인여부, 민팅 승인여부 (목표 설정에 대한 승인 여부는 선생님에게 있다.)
- 목표 설정을 저장하면 선생님의 승인여부는 false, 승인하면 true
- 목표 달성 인풋 : 학생 주소, 아웃풋 : Goal 구조체(어떤 과목, 세부 목표, 시작일, 종료일, 달성여부, 선생님 승인여부, 민팅 승인여부, 증명할 파일)
    증명할 파일을 피나타 API를 활용해서 프론트랑 연결 후 첨부파일을 넣어서 저장하면 pinata에 자동으로 올리고, 이미지 주소를 구조체에 최종적으로 넣어서 저장
- 목표 달성하면 달성여부 true, 민팅신청: 1. 학생이 민팅 신청, 민팅 신청 여부는 false 2. 선생님이 검토 후 승인, 민팅 신청 여부 true로 바뀜
- 선생님이 SBT의 메타데이터 입력(지갑 주소, 구체적인 노력 과정, 학생이 요청한 정보) 후 이에 맞는 NFT가 발행됨
*/

/*
이중매핑으로 msg.sender로 학생과 선생님을 구분할 수 있는지?
선생님이 학생들이 신청한 목표들을 모아서 볼 수 있게 하려면 무조건 배열로 짜야하는지
메타데이터를 임의로 작성해서 할 수 있다고 하면 어떻게 함수 짜야하는지
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StudentRecord is ERC721{

    constructor() ERC721("Badge", "B") {
    }

    struct Goal {
        address studentsAccount;
        address teachersAccount;
        string subjects;
        string detailGoal;
        uint startDate;
        uint endDate;
        status mintRequestStatus;
        string url;
    }

    enum status {
        yet,
        proceeding,
        approved
    }

    mapping (address => bool) isTeacher;
    mapping(uint => address) teachers;

    // 선생님이 맞다면 true로 설정 - 이걸 classTeacher함수 안에 넣어도 되는가가?
    function setTeacherAuthority() public {
        isTeacher[msg.sender] = true;
    }

    //선생님이 맞는지 확인(삭제)
    function getTeacherAuthority() public view returns(bool) {
        return isTeacher[msg.sender];
    }

    //몇 반 선생님인지 설정 - 각 반마다 선생님의 주소를 넣어주기(우선 선생님이 맞는지 확인)
    function classTeacher(uint _classNumber) public {
        require(isTeacher[msg.sender] == true, "not a teacher");
        require(_classNumber > 0,"bigger than zero");
        require(teachers[_classNumber] == address(0), "already existed class teacher"); // 이 기능이 필요할까
        teachers[_classNumber] = msg.sender;
    }

    // 각 반의 선생님의 주소 확인(삭제)
    function getClassTeacher(uint _classNumber) public view returns(address) {
        return teachers[_classNumber];
    }

    mapping(address => Goal[]) studentsGoals;
    Goal[] allGoals;
    uint contentsNumber;

    // 초기 목표 설정(어떤 과목, 세부 목표, 시작일, 종료일, 달성여부, 선생님 승인여부, 민팅 승인여부) - 학생이 실행
    function setGoal(uint _classNumber, string memory _subject, string memory _detail, uint _start, uint _end) public {
        require(bytes(_detail).length>0 && _start>0 && _end>0, "input value");
        require( _start < _end, "End date has to be later");
        require(teachers[_classNumber] != address(0), "there's no class teacher");
        studentsGoals[msg.sender].push(Goal(msg.sender, teachers[_classNumber], _subject, _detail, _start, _end, status.yet, ""));
        allGoals.push(Goal(msg.sender, teachers[_classNumber], _subject, _detail, _start, _end, status.yet,""));
    }

    // // 목표 수정(필요?)
    // function modifyGoal(uint _contentsNumber, string memory _subject, string memory _detail, uint _start, uint _end) public {
    //     require(bytes(_detail).length>0 && _start>0 && _end>0, "input value");
    //     require( _start < _end, "End date has to be later");
    //     studentsGoals[msg.sender][_contentsNumber] = Goal(msg.sender, _subject, _detail, _start, _end, status.yet, "");
    //     allGoals[_contentsNumber] = Goal(msg.sender, _subject, _detail, _start, _end, status.yet, "");
    // }

    // 학생이 본인이 설정한 목표 보기
    function getGoal() external view returns(Goal[] memory) {
        return studentsGoals[msg.sender];
    }

    // 선생님이 학생들의 목표 전체 보기(필요?)
    function allStudentsGoals() public view returns(Goal[] memory) {
        return allGoals;
    }

    // 목표 달성 후 증빙서류 제출 및 발행 신청 - 학생이
    // 피나타 주소 끌어와서 넣기
    function submitNApply(string memory _url, uint tokenId, uint _contentsNumber) public {
        require(bytes(_url).length > 0, "input value");
        studentsGoals[msg.sender][_contentsNumber].url = _url;
        studentsGoals[msg.sender][_contentsNumber].mintRequestStatus = status.proceeding;
        _mint(msg.sender, tokenId);
    }

    // 민팅 승인(민팅승인을 approved로 변경) - 선생님 권한
    function approveMinting(address _studentAddr, uint _contentsNumber, uint _classNumber) public {
        require(msg.sender == teachers[_classNumber]);
        require(studentsGoals[_studentAddr][_contentsNumber].mintRequestStatus == status.proceeding, "Status is not proceeding");
        studentsGoals[_studentAddr][_contentsNumber].mintRequestStatus = status.approved;
    }
}

