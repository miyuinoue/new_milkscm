class SuperTrack extends ArrayList <Track> {

  SuperTrack() {
  }

  void addtrack(Milk milk) {
    this.get(this.size()-1).super_addtrack(milk);
  }
}
