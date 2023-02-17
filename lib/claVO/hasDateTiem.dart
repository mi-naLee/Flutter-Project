class HasDateTime {

  final String hasDateTime;

  HasDateTime({
    required this.hasDateTime
  });

  get gethasDateTime => DateTime.utc(
                            int.parse(hasDateTime.substring(0,4)),
                            int.parse(hasDateTime.substring(5,7)),
                            int.parse(hasDateTime.substring(8,10))
                            );

  @override
  String toString() {
    // TODO: implement toString
    return gethasDateTime.toString();
  }
}