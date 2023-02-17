
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';


import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../alarm.dart';
import '../claVO/calve.dart';
import '../claVO/hasDateTiem.dart';
import '../database/dbcon.dart';
import '../utils.dart';
import '../weatherAPI/weather.dart';

class CcTt extends StatefulWidget {
  const CcTt({Key? key}) : super(key: key);

  @override
  State<CcTt> createState() {
    return _CcTtState();
  }
}

class _CcTtState extends State<CcTt> with SingleTickerProviderStateMixin {

  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = HasDateTime(hasDateTime: '${DateTime.now().toString()}').gethasDateTime;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Animation<double>? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    dbcontrol.getMap().then((value) => kEvents.addAll(value));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
    CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _animationController!
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  //=====================================================================

  final TextEditingController _titleController = TextEditingController();
  //미리 정해진 TextEditingController() 위젯을 사용
  // 이름 객채
  final TextEditingController _contentController = TextEditingController();
  // 전화번호 객체
  final dbcontrol = DBControll();

  void showBottomModal(
      // 199라인 정도에 있는 에디트 버튼을 눌렀을 때 이 메소드를 호출함
      BuildContext context2,//현제 위치를 알 수 있음
      ) {
    showModalBottomSheet(
      /*
        showModalBottomSheet 이것이 실제 사용하는 위쳇
        예를어서 수정 아이콘을 클릭했더니 배경쪽을 가리면서 sheet하나가 출력하도록
       */
      isScrollControlled: true,/////
      context: context2,// 현재위치 .... 화면상으로 현재 위치는???
      //BottomSheet가 보여지는 위치를 결정
      builder: (_){
        //buolder 버여줄 위젯을 나타낸다.
        //(BuildContext context){}의 생략형은 , _ 은 "인자 사용 안한다"는 의미
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(this.context).viewInsets.bottom+20, // this.context 수정 : error 발생
            //키보드가 어디선가 올라와서 나타나면 "가려지는 부분이 발생한다."
            /*
                    그러므로 버튼 같은 것을 키보드가 가려주게 되면 화면에 "공사중 표시(////////) 가 뜸
                    이때 일단
                    1) 임시로 해결방법은
                    SingleChildScrollView + resizeToAvoidBottomInset: true
                      ㄴ 화면을 고정하지 않고 위치를 재조정 한다. ->

                   2) 해결
                    MediaQuery... bottom 값을 구하여 키보드가 없으면 버튼이 그대로 있다가
                    MediaQuery.of(context).viewInsets.bottom ===> 키보드 높이
                    키보드가 올라가서 가리는 부분을 계산을 해서 버튼 등을 올려주기 때문에 가려지지 않는다.
                    키보드가 없으면 padding이 0이므로 bottomsheet가 아래에 그대로 있다가
                    편집을 위해 커서를 이름 부분에 클릭하면 키보드가 올라감
                    이럴 경우 키보드 높이가 50 이라면 50만큼 padding이 올라감
                 */
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding:
                    const EdgeInsets.only(top: 20,left: 20,right: 20),
                    child: Text('${_selectedDay.toString().substring(0,10)}에 일정을 추가 합니다.')
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(top: 20,left: 20,right: 20),
                  child: TextField(
                    /*
                          TextField의 특징은 validator:...
                          TextFormfield(
                              validator: (value) {
                                  if(value.isEmpty) {
                                  }
                              }
                          )
                       */
                    controller: _titleController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),labelText: 'Title'
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Content'
                    ),
                    maxLines: 3,
                  ),

                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          dbcontrol.insertEmp(
                              _titleController.text,
                              _contentController.text,
                              _selectedDay.toString().substring(0,10));
                          _titleController.clear();
                          _contentController.clear();
                          //상태관리 시 아래 작업
                          //즉, 수정된 내용을 db에 update
                          // 이름, 전화 번호
                        });// 수정된 내용은 dbcontrl.dart로 가서 수정 저장
                        Navigator.of(context2).pop();//현재 화면 삭제
                        //stack 형식 pop,push
                      },
                      icon: Icon(Icons.edit),
                      label: Text("일정 저장"),
                    )
                ),
              ],

            ),
          ),
        );
      },
    );
  }

  void showBottomModalUpdate(
      BuildContext context2,//현제 위치를 알 수 있음
      String id,
      String title,
      String content
      ) {
    final TextEditingController _updateTitleController = TextEditingController();
    final TextEditingController _updateContentController = TextEditingController();

    _updateTitleController.text = title;
    _updateContentController.text = content;

    showModalBottomSheet(
        isScrollControlled:true,
        context:context2,
        builder: (_){
          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(this.context).viewInsets.bottom+20, // this.context 사용 : error 발생

            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 20,left: 20,right: 20),
                    child: TextField(
                      controller: _updateTitleController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),labelText: 'Title'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                    child: TextField(
                      controller: _updateContentController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Content'
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            //상태관리 시 아래 작업
                            //즉, 수정된 내용을 db에 update
                            dbcontrol.updateEmp(
                                id,
                                _updateTitleController.text,
                                _updateContentController.text,
                                _selectedDay.toString().substring(0,10));// 이름, 전화 번호
                          });// 수정된 내용은 dbcontrl.dart로 가서 수정 저장
                          Navigator.of(context2).pop();//현재 화면 삭제
                          //stack 형식 pop,push
                        },
                        icon: Icon(Icons.edit),
                        label: Text("일정 수정"),
                      )
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('일정 관리 앱'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: dbcontrol.getMap(),
                      builder: (context, snapshot) {

                        kEvents.clear();

                        if(snapshot.hasData){
                          kEvents.addAll(snapshot.data as Map<DateTime,List<Event>>);
                        }else
                          {
                            kEvents.clear();
                          }
                        return TableCalendar<Event>(
                          locale: 'ko-KR',
                          firstDay: kFirstDay,
                          lastDay: kLastDay,
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          //rangeStartDay: _rangeStart,
                          //rangeEndDay: _rangeEnd,
                          calendarFormat: _calendarFormat,
                          //rangeSelectionMode: _rangeSelectionMode,
                          eventLoader: _getEventsForDay,
                          startingDayOfWeek: StartingDayOfWeek.sunday,
                          calendarStyle: CalendarStyle(// Use `CalendarStyle` to customize the UI
                              outsideDaysVisible: false,
                              weekendTextStyle: TextStyle(color: Colors.red)
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle: TextStyle(color: Colors.red,),
                              dowTextFormatter: (date, locale) {
                                return DateFormat.E(locale).format(date)[0];
                              }
                          ),
                          daysOfWeekHeight: 30,
                          onDaySelected: _onDaySelected, //onRangeSelected: _onRangeSelected,
                          onFormatChanged: (format) {
                            if(_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }},
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        );
                      },),
                    const SizedBox(height: 8.0),
                    weatherAPI(),
                    Column(
                        children: <Widget>[ FutureBuilder(
                            future: dbcontrol.getEmps(_selectedDay.toString().substring(0,10)),
                            builder: (context3, snap){
                              List<CalVO> calList = snap.data as List<CalVO>;
                              if((snap.data as List<CalVO>)==null){
                                return Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 20,
                                    child: Text('일정없음'),
                                  ),
                                );
                              }
                              List<Widget> Listw = [];
                              for(int i = 0; i < calList.length; i++){
                                Listw.add(Card(
                                    elevation: 3,
                                    child: CheckboxListTile(
                                        title: Text('${calList[i].title}'),
                                        subtitle: Text('${calList[i].content}'),
                                        activeColor: Colors.lightBlue,
                                        checkColor: Colors.white,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: calList[i].checkBox==1? true:false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if(calList[i].checkBox == 0){
                                              //checked = true;
                                              dbcontrol.updatecheckBox(calList[i].id, 1);
                                            }else{
                                              dbcontrol.updatecheckBox(calList[i].id, 0);
                                            }
                                          });
                                        },
                                        secondary: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: <Widget>[
                                              IconButton(
                                                  onPressed: () => showBottomModalUpdate(
                                                      context3,
                                                      calList[i].id,
                                                      calList[i].title,
                                                      calList[i].content),
                                                  icon: Icon(Icons.edit)
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      dbcontrol.deleteEmp(calList[i].id);
                                                    });
                                                  },
                                                  icon:  Icon(Icons.delete)
                                              )
                                            ],
                                          ),
                                        )

                                    )
                                ));
                              };

                              Iterator<Widget> itter = Listw.iterator;

                              if(itter.moveNext()){
                                return Column( children: Listw,);
                              }
                              
                              return Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 20,
                                  child: Text('일정없음'),
                                ),
                              );
                            }
                        ),
                        ]
                    )// 날씨 bar 불러오는 부분(Padding Widget)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionBubble(items: <Bubble>[
                    Bubble(
                        icon: Icons.alarm,
                        iconColor: Colors.white,
                        title: "Alarm",
                        titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                        bubbleColor: Colors.blueAccent,
                        onPress: (){
                          setState(() {
                            runApp(MyApp());
                          });
                        }),
                    Bubble(
                        icon: Icons.add_circle_outline,
                        iconColor: Colors.white,
                        title: "Schedule",
                        titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                        bubbleColor: Colors.blueAccent,
                        onPress: (){
                          showBottomModal(context);
                        })
                  ],
                    animation: _animation!,
                    onPress: () => _animationController!.isCompleted
                        ? _animationController!.reverse()
                        : _animationController!.forward(),
                    backGroundColor: Colors.blue,
                    iconColor: Colors.white,
                    iconData: Icons.menu,
                  ),
                ),
              )]
          )
        )
    );
  }
}