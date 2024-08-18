@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  pathStack:NavPathStack = new NavPathStack()

  @Builder
  PagesMap(name:string) {
    if(name == 'HomePage') {

    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text(this.message)
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })

        Button('跳转')
          .width(80)
          .type(ButtonType.Capsule)
          .onClick(() => {
             this.pathStack.pushPathByName('HomePage', null, true)
          })
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.Pink)
    }
    .title('标题')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)

  }
}


