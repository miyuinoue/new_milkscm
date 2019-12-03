class Milk {
  int expiration;
  int price;

  Milk() {
    price = -1;
  }

  void newmilk() {
    this.expiration = E;
  }

  void daychange() {
    this.expiration--;
  }

  //買わない牛乳を選択した場合は、賞味期限が100と表示される
  void notbuymilk() {
    this.expiration = 100;
  }
}
