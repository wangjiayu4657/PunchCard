import StatisticsItem from '../componets/StatisticsItem'
import { promptAction } from '@kit.ArkUI'
import { getRandomQuestions, Question } from '../models/Qustion'
import AnswerItem from '../componets/AnswerItem'
import { convertMillisecondsToTime } from '../componets/DateUtil'

//答题状态
export enum AnswerState {
  /** 正在答题 */
  running,
  /** 暂停答题 */
  paused,
  /** 停止答题 */
  stopped,
}

enum OptionType {
  /* 关闭 */
  close,
  /* 再来一局 */
  again,
  /* 登录打卡 */
  login
}


@Entry
@Component
struct HomePage {
  //题目总数量
  @State totalCount:number = 5
  //问题索引, 用于开始下一题
  @State nextIdx: number = 0
  //当前选中的索引
  @State isSelected: boolean = false
  //答题状态
  @State answerState: AnswerState = AnswerState.stopped
  //问题数据源
  @State questions: Question[] = getRandomQuestions(10)
  //获取当前选中的问题
  @State question: Question = this.questions[this.nextIdx]
  //记录答对的题目数量
  rightCount:number = 0
  //答题准确率
  @State accuracy: number = 0
  //答题使用的时间
  timeUsed:number = 0

  //时间控制器
  timeCtrl: TextTimerController = new TextTimerController()

  //答题数量输入弹窗
  inputDialogCtrl:CustomDialogController = new CustomDialogController({
    builder: InputDialog({
      count: this.totalCount,
      confirm: (count:number) => {
        this.reset(count)
      }
    }),
    autoCancel: true,
    customStyle: true,
  })

  //结果弹窗
  resultDialogCtrl:CustomDialogController = new CustomDialogController({
    builder: AnswerResultDialog({
      time: this.timeUsed,
      count: this.nextIdx.toString(),
      accuracy:this.accuracy,
      callBack: (type:OptionType) => {
        if(type == OptionType.close) {
          this.reset(this.totalCount)
        } else if(type == OptionType.again) {
          this.reset(this.totalCount)
          this.startAnswer()
        } else {
          console.log('登录打卡')
        }
      }
    }),
    customStyle:true
  })




  build() {
    Column({ space: 20 }) {
      //统计
      this.statisticsCardBuilder()

      //题目
      this.questionCardBuilder()

      //选项
      this.questionItemBuilder()

      //操作
      this.operationBuilder()
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundImage($r('app.media.img_practice_bg'))
  }

  //统计组件
  @Builder
  statisticsCardBuilder() {
    Column({ space: 15 }) {
      //统计选相卡
      StatisticsItem({
        name: '准确率',
        icon: $r('app.media.ic_accuracy'),
      }) {
        Text(`${(this.accuracy * 100).toFixed(2)} %`)
          .width(100)
          .textAlign(TextAlign.Center)
      }

      StatisticsItem({
        name: '进度',
        icon: $r('app.media.ic_progress'),
      }) {
        Progress({ value: this.nextIdx, total: this.totalCount })
          .width(100)
          .color(Color.Blue)
      }

      StatisticsItem({
        name: '个数',
        icon: $r('app.media.ic_count'),
      }) {
        Button(this.totalCount.toString())
          .width(100)
          .height(25)
          .backgroundColor('#EBEBEB')
          .fontColor(Color.Black)
          .onClick(() => {
            this.inputDialogCtrl.open()
          })
      }

      StatisticsItem({
        name: '用时',
        icon: $r('app.media.ic_timer'),
      }) {
        Row() {
          TextTimer({ controller: this.timeCtrl })
            .onTimer((utc: number, elapsedTime: number) => {
              this.timeUsed = elapsedTime * 10
            })
        }
        .width(100)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('90%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .padding(15)
    .margin({ top: 10 })
  }

  //问题组件
  @Builder
  questionCardBuilder() {
    Column({ space: 10 }) {
      Text(this.getQuestion().word)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text(this.getQuestion().sentence)
        .fontSize(14)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding(15)
  }

  //问题选项组件
  @Builder
  questionItemBuilder() {
    Column({ space: 15 }) {
      ForEach(
        this.getQuestion().options,
        (answer: string) => {
          AnswerItem({
            isSelected: this.isSelected,
            answer: answer,
            answerState: this.answerState,
            question: $question,
            callBack: (isSelected: boolean, answer?:string) => {
              this.handlerSelQuestion(isSelected, answer)
            }
          }
          )
        }, (answer: string) => answer + this.getQuestion().options)
    }
    .width('100%')
  }

  //操作组件
  @Builder
  operationBuilder() {
    Row() {
      Button('结束测试')
        .btnStyle({
          bgColor: Color.Transparent,
          fontColor: this.answerState === AnswerState.stopped ? Color.Gray : Color.Black,
          bordColor: this.answerState === AnswerState.stopped ? Color.Gray : Color.Black
        })
        .enabled(this.answerState !== AnswerState.stopped)
        .onClick(() => this.stopAnswer())

      Button(this.answerState === AnswerState.running ? '暂停测试' : '开始测试')
        .btnStyle({
          fontColor: Color.White,
          bordColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
          bgColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
        })
        .onClick(() => {
          if (this.answerState == AnswerState.running) {
            this.pauseAnswer()
          } else {
            this.startAnswer()
          }
        })
    }
    .width('100%')
    .margin({ top: 10 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  getQuestion():Question {
    let idx = this.nextIdx < this.questions.length ? this.nextIdx : this.questions.length - 1
    let question = this.questions[idx]
    return question
  }

  //处理点击选择答题选项
  handlerSelQuestion(isSelected: boolean, answer?:string) {
    if (this.answerState != AnswerState.running) {
      promptAction.showToast({ message: '请先点击开始测试' })
      this.isSelected = false
      return
    }

    this.timeCtrl.start()

    //当前选中的选项
    this.isSelected = isSelected
    //获取当前选中的问题
    if(this.nextIdx < this.questions.length) {
      this.question = this.questions[this.nextIdx]
    }

    if(this.question.answer === answer) {
      this.rightCount++
    }

    if (this.nextIdx < this.totalCount ) {
      setTimeout(() => {
        this.nextIdx += 1
        console.log(`nextId == ${this.nextIdx}  totalCount == ${this.totalCount}`)
        //重置下一题的选中状态
        this.isSelected = false
        this.accuracy = this.rightCount / this.nextIdx
        if(this.nextIdx == this.totalCount) {
          this.stopAnswer()
        }
      }, 700)
    }

    console.log('selIdx == ', this.nextIdx)
  }

  //开始答题
  startAnswer() {
    if (this.answerState == AnswerState.running) {
      this.timeCtrl.pause()
      this.answerState = AnswerState.paused
    } else {
      //开启计时
      this.timeUsed = Date.now()
      this.timeCtrl.start()
      this.answerState = AnswerState.running
    }
  }

  //暂停答题
  pauseAnswer() {
    this.timeCtrl.pause()
    this.answerState = AnswerState.paused
  }

  //结束答题
  stopAnswer() {
    this.timeCtrl.pause()
    this.answerState = AnswerState.stopped
    this.resultDialogCtrl.open()
  }

  //重新选择答题数量时需要重置
  reset(count:number) {
    this.nextIdx = 0
    this.accuracy = 0
    this.rightCount = 0
    this.totalCount = count
    this.timeCtrl.reset()
    this.answerState = AnswerState.stopped
    this.questions = getRandomQuestions(this.totalCount)
  }
}


//答题数量输入弹窗
@CustomDialog
struct InputDialog {
  count:number = 0
  confirm?: (count:number) => void
  ctrl?: CustomDialogController

  build() {
    Column({ space: 15 }) {
      //标题
      Text('请输入数量')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      //输入框
      TextInput({ text: this.count.toString(), placeholder: '请输入答题数量' })
        .onChange((count: string) => this.count = parseInt(count))
        .type(InputType.Number)

      //操作按钮
      Row({ space: 30 }) {
        Button('取消')
          .width(100)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.ctrl?.close()
          })

        Button('确定')
          .width(100)
          .backgroundColor(Color.Green)
          .onClick(() => {
            this.confirm ? this.confirm(this.count) : null
            this.ctrl?.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('90%')
    .padding(15)
    .borderRadius(8)
    .backgroundColor(Color.White)
  }
}

// @Preview
@CustomDialog
struct AnswerResultDialog {
  //用时
  time:number = 0
  //答题个数
  count:string = '0'
  //准确率
  accuracy: number = 0
  //弹窗控制器
  ctrl?: CustomDialogController
  //回调
  callBack?:(type:OptionType) => void

  build() {
    Column() {
      //关闭按钮
      Image($r('app.media.ic_close'))
        .width(30)
        .fillColor(Color.White)
        .alignSelf(ItemAlign.End)
        .margin({top: 15, bottom: 15})
        .onClick(() => {
          this.ctrl?.close()
          this.callBack ? this.callBack(OptionType.close) : null
        })

      Column({ space: 15 }) {
        //图片
        Image($r('app.media.img_post'))
          .width('94%')

        Column({ space: 15 }) {
          //答题用时
          StatisticsItem({
            name: '用时',
            icon: $r('app.media.ic_timer'),
          }) {
            Text(convertMillisecondsToTime(this.time))
          }

          //答题准确率
          StatisticsItem({
            name: '准确率',
            icon: $r('app.media.ic_accuracy'),
          }) {
            Text(`${(this.accuracy * 100).toFixed(2)} %`)
          }

          //答题个数
          StatisticsItem({
            name: '个数',
            icon: $r('app.media.ic_count'),
          }) {
            Text(this.count)
          }

          //分割线
          Divider().margin({ top: 5 })
        }
        .width('90%')

        //操作按钮
        Row({ space: 30 }) {
          Button('再来一局')
            .width(100)
            .fontColor(Color.Gray)
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: Color.Gray })
            .onClick(() => {
              this.ctrl?.close()
              this.callBack ? this.callBack(OptionType.again) : null
            })

          Button('登录打卡')
            .width(100)
            .backgroundColor(Color.Black)
            .onClick(() => {
              this.ctrl?.close()
              this.callBack ? this.callBack(OptionType.login) : null
            })
        }
        .width('100%')
        .margin({ top: 5 })
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .borderRadius(8)
      .padding({
        top: 20,
        left: 15,
        bottom: 20,
        right: 15
      })
      .backgroundColor(Color.White)
    }
    .width('90%')
    .backgroundColor(Color.Transparent)
  }
}


interface BtnColor {
  bgColor: ResourceStr | Color;
  fontColor: ResourceStr | Color;
  bordColor: ResourceStr | Color;
}

@Extend(Button)
function btnStyle(color: BtnColor) {
  .width(100)
  .height(40)
  .type(ButtonType.Capsule)
  .border({ width: 1, color: color.bordColor })
  .backgroundColor(color.bgColor)
  .fontColor(color.fontColor)
}



/*
@CustomDialog
struct InputPicker {
  count:string = '0'
  ctrl?: CustomDialogController
  build() {
    Column() {
      TextPicker({
        range: ['5', '10', '15', '20'],
        value: this.count
      })
        .canLoop(false)
        .onChange((value: string | string[], index: number | number[]) => {
          console.log(`value == ${value}  idx: == ${index}`)
        })

      //操作按钮
      Row({ space: 30 }) {
        Button('取消')
          .width(100)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.ctrl?.close()
          })

        Button('确定')
          .width(100)
          .backgroundColor(Color.Green)
          .onClick(() => {
            this.ctrl?.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
  }
}
*/