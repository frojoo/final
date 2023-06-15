// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/*
학생은 user, 선생님이 NFT확정 지을 수 있는 권한 있음
선생님만 스마트컨트랙트 Owner, 배포한 계정이 주소를 mapping 해줄 수 있게끔
struct 구조가 잇으면 input값은 address, output 값은 권한
지갑 주소를 넣으면 권한을 조회할 수 있는 mapping 하나 만들기
require로 선생님이 건들 함수 분류 가능
권한이 struct로 가야하긴 함, 최종적으로는 / 처음에는 t/f로만
*/

contract StuentRecord {
    address teacher;

    // 발행자를 선생님으로
    constructor() {
        teacher = msg.sender;
    }

    // 권한 설정
    modifier onlyTeacher() {
        require(msg.sender == teacher, "Only teacher can call this function.");
        _;
    }

    // 학생의 정보는 이름, 번호, 과목별 점수, 자격증 및 수상경력, 봉사활동, 독서
    struct Student {
        string name;
        uint number;
        mapping(string => uint) subjectScore;
        uint prize;
        uint volunteer;
        uint book;
    }
    // ******과목 별 점수를 점수 하나씩 나오게 해야되나, 아니면 과목별 점수를 한꺼번에 보여줘야 되나******

    mapping(address => Student) students;

    //학생 정보 기입
    function setStuent(address _addr, string memory _name, uint _number, uint _prize, uint _volunteer, uint _book) public {
        students[_addr].name = _name;
        students[_addr].number = _number;
        students[_addr].prize = _prize;
        students[_addr].volunteer = _volunteer;
        students[_addr].book = _book;

        
    }

    // 과목별 점수 설정
    function setSubjectsScore(address _addr, uint _korean, uint _math, uint _science, uint _social, uint _english) public {
        Student storage student = students[_addr];
        student.subjectScore["Korean Language"] = _korean;
        student.subjectScore["Math"] = _math;
        student.subjectScore["Science"] = _science;
        student.subjectScore["Social Studys"] = _social;
        student.subjectScore["English"] = _english;
    }

    // 과목별 점수 보기
    function getSubjectsScore(address _addr, string memory _subject) public view returns(uint) {
        return (students[_addr].subjectScore[_subject]);
    }

    // 학생 정보 보기
    function getStudent(address _addr, string memory _subject) public view returns(string memory, uint, uint, uint, uint, uint) {
        return (students[_addr].name, students[_addr].number, getSubjectsScore(_addr, _subject), students[_addr].prize, students[_addr].volunteer, students[_addr].book);
    }
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

contract TEACHER {
    mapping(address => bool) permissions; // 선생님 권한

    function getPermission(address _tAddress) internal {
        permissions[_tAddress] = true;
    }

    modifier onlyTeacher(address _tAddress) {
        require(permissions[_tAddress] == true,"only teacher can call this function");
        _;
    }
}