// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/*
solidity로 학생부를 만들려고한다.
fontend에서 학생 전용 id와 비밀번호를 입력하고, 선생님 전용 id와 비밀번호를 입력해 접속한다.
학생이 본인의 학생부 기록의 목표를 입력해서 달성하면 ERC-721을 활용해 소울바운드토큰을 발행해주는 기능을 만드려고한다.
학생 이름, 번호, 지갑주소, 과목별 점수(국어, 수학, 영어, 과학, 사회, 예체능), 봉사활동 횟수, 상장 개수를 포함한 구조체를 만든다.
학생이 학생부를 기록해서 NFT 민팅 신청을 하면 선생님만이 검토 후 발행을 완료해주는 역할을 만드려고 한다.
학생부를 작성하는 함수를 만들고 각 하나씩을 변경하는 기능도 만든다.
*/

/*
목표설정은 프론트엔드에서 할것인지?
프론트엔드의 아이디 비번을 솔리디티로까지 불러올것인지

*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StudentRecord is ERC721{
    address teacher;

    // 발행자를 선생님으로
    constructor() ERC721("Badge", "B") {
        teacher = msg.sender;
    }

    // 권한 설정
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
    }

    mapping(address => Student) students;

    //학생 정보 기입
    function setStudent(address _studentAddress, string memory _name, uint _number, uint[] memory _score, string[] memory _prizes, string[] memory _books) public {
        students[_studentAddress] = Student(_name, _number, _score, _prizes, _prizes.length, 0, _books, _books.length, false);
    }
    
    // 학생 정보 보기
    function getStudent(address _studentAddress) public view returns(Student memory) {
        return students[_studentAddress];
    }

    // 과목별 점수 업데이트
    function updateScores(address _studentAddress, uint _subjectNumber, uint _score) public {
        require(_subjectNumber <students[_studentAddress].subjectScore.length);

        students[_studentAddress].subjectScore[_subjectNumber] = _score;
    }
    
    // 과목 점수 보기
    function getSubjectsScore(address _studentAddress) public view returns(uint[] memory) {
        return students[_studentAddress].subjectScore;
    }

    // 상장 업데이트
    function updatePrizes(address _studentAddress, string memory _prize) public {
        students[_studentAddress].prizes.push(_prize);
    }

    // 봉사시간 업데이트
    function updateVolunteerHours(address _studentAddress, uint _volunteer) public {
        students[_studentAddress].volunteer += _volunteer;
    }

    // 독서 업데이트
    function updateBooks(address _studentAddress, string memory _book) public {
        students[_studentAddress].books.push(_book);
    }

    // 민팅 신청
    function _mintToken(address _studentAddress) public {
        students[_studentAddress].mintRequest = true;
    }

}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

contract TEACHER is StudentRecord {
    StudentRecord SR;

    mapping(address => bool) permissions; // 선생님 권한

    

    function getPermission() internal {
        permissions[msg.sender] = true;
    }

    modifier onlyTeacher() {
        require(permissions[msg.sender] == true);
        _;
    }

    function approveMint(address _studentAddress, uint tokenId) public onlyTeacher {
        require(students[_studentAddress].mintRequest == true);

        _mint(_studentAddress, tokenId);
        // students[_studentAddress].mintRequest = false; 변수 바꾸려면 인스턴스화 하고 바꿔줘야 되는거 아닌가
    }

    function refuseMint() public onlyTeacher {

    }
}