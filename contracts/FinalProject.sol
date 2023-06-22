// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/*
solidity로 학생부를 만들려고한다.
학생이 본인의 학생부 기록의 목표를 입력해서 달성하면 ERC-721을 활용해 소울바운드토큰을 발행해주는 기능을 만드려고한다.
학생 이름, 번호, 지갑주소, 과목별 점수(국어, 수학, 영어, 과학, 사회, 예체능), 봉사활동 횟수, 상장 개수를 포함한 구조체를 만든다.
목표를 저장할 수 있는 구조체를 만들고 이를 학생의 구조체에 포함시키려한다. 목표 설정에 대한 승인 여부는 선생님에게 있다.
학생이 학생부를 기록해서 NFT 민팅 신청을 하면 선생님만이 검토 후 발행을 완료해주는 역할을 만드려고 한다.
학생부를 작성하는 함수를 만들고 각 하나씩을 변경하는 기능도 만든다.
*/

/*
선생님이 목표 설정과 최종 민팅확정에 대한 권한을 주려고 하는데 컨트랙트를 2개로 나눠서 하는게 맞는지?
목표설정을 할때 과목이나 분야를 어떻게 끌고 올지
위 컨트랙트에서는 학생을 msg.sender라고 했는데 아래 선생님에서의 msg.sender는 어떻게 다르게 하는지
목표를 설정하는 구조체에서 학생 구조체 안에 있는 상장, 성적, 봉사 등을 사용하고 연동하고 싶은데 어떻게 해야하는지? 아님 다른 방법이 있는지?
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StudentRecord is ERC721{
    constructor() ERC721("Badge", "B") {
    }

    // // 권한 설정
    // modifier onlyTeacher() {
    //     require(msg.sender == teacher, "Only teacher can call this function.");
    //     _;
    // }

    // 학생의 정보는 이름, 번호, 과목별 점수, 자격증 및 수상경력, 봉사활동, 독서
    struct Student {
        string name;
        uint number;
        uint[] subjectScore;
        string[] prizes;
        uint countPrize;
        uint volunteer;
        string[] books;
        uint countBooks;
        bool mintRequest;
        Goal[] individualGoals;
    }

    struct Goal {
        // string[] fields;
        string detailGoal;
        uint startDate;
        uint endDate;
        bool approved;
        bool achievement;
    }

    mapping(address => Student) students;

    //학생 정보 기입
    function setStudent(string memory _name, uint _number, uint[] memory _score, string[] memory _prizes, string[] memory _books) public {
        Goal[] memory goals = students[msg.sender].individualGoals;
        
        students[msg.sender] = Student(_name, _number, _score, _prizes, _prizes.length, 0, _books, _books.length, false, goals);
    }
    
    // 학생 정보 보기
    function getStudent() public view returns(Student memory) {
        return students[msg.sender];
    }

    // 목표 설정
    function setGoal(string memory _detail, uint _start, uint _end) public {
        students[msg.sender].individualGoals.push(Goal(_detail, _start, _end, false, false));
    }

    // // 목표 설정 승인
    // function approveGoal() internal {}

    // 과목별 점수 업데이트
    function updateScores(uint _subjectNumber, uint _score) public {
        require(_subjectNumber <students[msg.sender].subjectScore.length);

        students[msg.sender].subjectScore[_subjectNumber] = _score;
    }
    
    // 과목 점수 보기
    function getSubjectsScore() public view returns(uint[] memory) {
        return students[msg.sender].subjectScore;
    }

    // 상장 업데이트
    function updatePrizes(string memory _prize) public {
        students[msg.sender].prizes.push(_prize);
    }

    // 봉사시간 업데이트
    function updateVolunteerHours(uint _volunteer) public {
        students[msg.sender].volunteer += _volunteer;
    }

    // 독서 업데이트
    function updateBooks(string memory _book) public {
        students[msg.sender].books.push(_book);
    }

    // 민팅 신청
    function _mintToken() public {
        students[msg.sender].mintRequest = true;
    }

    // 민팅 승인
    function approveMint(address _studentAddress, uint tokenId) internal {
        require(students[_studentAddress].mintRequest == true);

        _mint(_studentAddress, tokenId);
        students[_studentAddress].mintRequest = false;
    }

    // 민팅 거절
    function refuseMint() internal {}

    function getMsgsender() internal view returns(address) {
        return msg.sender;
    }
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

contract TEACHER is StudentRecord() {
    StudentRecord SR;
    // StudentRecord SR = new StudentRecord(); 이건 컨트랙트 주소가 나오는거 아닌지

    address teacher;

    // 선생님 권한
    modifier onlyTeacher() {
        require(msg.sender == teacher, "Only teacher can call this function.");
        _;
    }

    function approveMintRequest(uint tokenId) public onlyTeacher{
        approveMint(super.getMsgsender(), tokenId);
    }

    function compare() public view returns(address, address) {
        return (StudentRecord.getMsgsender(), msg.sender);
    }

    // function approveMint(address _studentAddress, uint tokenId) public onlyTeacher {
    //     require(students[_studentAddress].mintRequest == true);

    //     _mint(_studentAddress, tokenId);
    //     // students[_studentAddress].mintRequest = false; 변수 바꾸려면 인스턴스화 하고 바꿔줘야 되는거 아닌가
    // }

    // function refuseMint() public onlyTeacher {

    // }
}