
@Entry
@Component
struct HomeDetailPage {
  @State message: string = 'Hello World';

  build() {
    NavDestination() {
      Text(this.message)
        .id('HomeDetailPageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}