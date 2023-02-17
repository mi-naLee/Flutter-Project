

import '../claVO/calve.dart';
import '../claVO/hasDateTiem.dart';
import '../utils.dart';
import 'dbDAO.dart';
import 'package:get/get.dart';

class DBControll {
  //daomodel/dbcontroll.dart
  Future<List<CalVO>> getEmps(String seletdate) async {
    // getEmps를 호출하면 전체 사원명단 return
    final CalList = await DatabaseHelper.getCal('calt',seletdate);
    // Java에서 ArrayList에 vo를 담는 형태
    return CalList.map((item) =>
        CalVO(
            id: item['id'] as String,
            title: item['title'] as String,
            content: item['content'] as String,
            startd: item['startd'] as String,
            endd: item['endd'] as String,
            checkBox: item['checkBox'] as int,
        )).toList();
  }

  Future<List<CalVO>> getAllEmps() async {
    // getEmps를 호출하면 전체 사원명단 return
    final CalList = await DatabaseHelper.getAllCal('calt');
    // Java에서 ArrayList에 vo를 담는 형태
    return CalList.map((item) =>
        CalVO(
            id: item['id'] as String,
            title: item['title'] as String,
            content: item['content'] as String,
            startd: item['satrtd'] as String,
            endd: item['endd'] as String,
            checkBox: item['checkBox'] as int,
        )).toList();
  }

  void insertEmp(String title, String content,String startd) {
    //사원을 추가 한다.
    //insertSawon(String dbt, Map<String, Object> data)
    int check = 0;
    DatabaseHelper.insertCal(
        'calt', {'id':DateTime.now().toString(), 'title':title, 'content': content, 'startd':startd, 'checkBox': check}
    );
    //테이블명 직접, data를 입력한다.
    //오라클이라면 seq.nextval 역할을 한다.
    //print("insert 전송 ${startd} + ${title} + ${content}");

  }

  void deleteEmp(String id){
    DatabaseHelper.deleteCal('calt', id);
  }

  void updateEmp(String id, String title, String content,String startd) {
    DatabaseHelper.updateCal('calt', {'title':title,'content':content}, id);
  }

  void updatecheckBox(String id, int check){ // check
    DatabaseHelper.updateCal('calt', {'checkBox':check}, id);
  }

  //---------------------------------------------
  Future<List<HasDateTime>> getDateTimes() async{
    final DateTimeList = await DatabaseHelper.getDateTimes('calt');
    return DateTimeList.map((item) =>
        HasDateTime(hasDateTime : item['startd'] as String)).toList();
  }
  Future<List<Event>> getEvents(String startd) async{
    final DateTimeList = await DatabaseHelper.getEvents('calt', startd);
    return DateTimeList.map((item) =>
        Event(item['content'] as String
        )).toList();
  }
  
  Future<Map<DateTime,List<Event>>> getMap() async{

    //{for (var v in iterable) key(v): value(v)}
    List<HasDateTime> _dateTimeList = await getDateTimes().then((value) => value);

    Map<DateTime,List<Event>> getMap1 = {};

    for(var v in _dateTimeList) {
      List<Event> _eventList = await getEvents(v.toString().substring(0,10)).then((value) => value);

      getMap1.putIfAbsent(v.gethasDateTime, () => _eventList);
    }

    return getMap1;
  }

  Future<List<Event>> getUpdateEvents(String startd) async {

    List<Event> updateList = await getEvents(startd).then((value) => value);

    return updateList;
  }
}