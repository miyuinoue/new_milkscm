class Milk {
  int expiration;
  int price;
  int waste;

  Milk() {
    this.price = -1;
    this.waste = -1;//廃棄でない牛乳はー１
  }

  void newmilk() {
    this.expiration = E;
  }

  void daychange() {
    this.expiration--;
  }

  void waste() {
    this.waste = 1;//廃棄の牛乳は１
  }

  //買わない牛乳を選択した場合は、賞味期限が100と表示される
  void notbuymilk() {
    this.expiration = 100;
  }
}
