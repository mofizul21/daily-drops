class Drop {
  final String userName;
  final String userIconUrl; 
  final String dropText;
  int loveCount;
  int ashLoveCount;

  Drop({
    required this.userName,
    required this.userIconUrl,
    required this.dropText,
    this.loveCount = 0,
    this.ashLoveCount = 0,
  });
}
