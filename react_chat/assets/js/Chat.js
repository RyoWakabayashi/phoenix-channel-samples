import React from "react";
import {Socket, Presence} from "phoenix"
import RaisedButton from 'material-ui/RaisedButton';
import Paper from 'material-ui/Paper';
import Divider from 'material-ui/Divider';
import TextField from 'material-ui/TextField';

class Chat extends React.Component {
  constructor() {
    super();
    this.state = {
      isJoined: false,  //joinしているかどうか。画面を切り替える。
      inputUser: "",    //ユーザ名の入力
      inputMessage: "", //メッセージの入力
      messages: [],     //受け取ったメッセージの配列
      presences: {}     //presence(参加ユーザ)の状態
    }
  }

  handleInputUser(event) {
    this.setState({
      inputUser: event.target.value
    })
  }

  handleInputMessage(event) {
    this.setState({
      inputMessage: event.target.value
    })
  }

  // join処理
  handleJoin(event) {
    event.preventDefault();
    if(this.state.inputUser!="") {

        // assets/js/socket.jsのデフォルトの定義と同じ
        this.socket = new Socket("/socket", {params:
          {token: window.userToken}
        });
        this.socket.connect();

        this.channel = this.socket.channel("room:lobby",  {user_name: this.state.inputUser});

        // Presences：現在のサーバの状態を初期状態として設定
        this.channel.on('presence_state', state => {
          let presences = this.state.presences;
          presences = Presence.syncState(presences, state);
          this.setState({ presences: presences })
          console.log('state', presences);
        });

        // Presences：初期状態からの差分を更新していく
        this.channel.on('presence_diff', diff => {
          let presences = this.state.presences;
          presences = Presence.syncDiff(presences, diff);
          this.setState({ presences: presences })
          console.log('diff', presences);
        });

        // メッセージを受け取る処理
        this.channel.on("new_msg", payload => {
          let messages = this.state.messages;
          messages.push(payload)
          if (messages.length > 10) {
            messages.shift()
          }
          this.setState({ messages: messages })
        })

        // channelにjoinする
        this.channel.join()
          .receive("ok", response => { console.log("Joined successfully", response) })
          .receive('error', resp => { console.log('Unable to join', resp); });

        this.setState({ isJoined: true })
    }
  }

  // 退室の処理 socketを切断するだけ。これでいいのか？
  handleLeave(event) {
    event.preventDefault();
    this.socket.disconnect();
    this.setState({ isJoined: false })
  }

  // メッセージ送信の処理
  handleSubmit(event) {
    event.preventDefault();
    this.channel.push("new_msg", {msg: this.state.inputMessage})
    this.setState({ inputMessage: "" })
  }

  // 画面表示
  render() {
    const style1 = { margin: '16px 32px 16px 16px', padding: '10px 32px 10px 26px',};
    const style2 = { display: 'inline-block', margin: '1px 8px 1px 4px',};

    const messages = this.state.messages.map((message, index) => {
        return (
            <div key={index}>
              <p><strong>{message.user_name}</strong> &gt; {message.msg}</p>
            </div>
        )
    });

    let presences = Presence.list(this.state.presences);

    let form_jsx;
    if(this.state.isJoined===false) {
       form_jsx = (
        <form onSubmit={this.handleJoin.bind(this)} >
          <label>ユーザ名を指定してJoin</label>&nbsp;&nbsp;&nbsp;&nbsp;
          <TextField hintText="ユーザ名" value = {this.state.inputUser} onChange = {this.handleInputUser.bind(this)} />&nbsp;&nbsp;&nbsp;&nbsp;
          <RaisedButton type="submit" primary={true} label="Join" />
        </form>
       );
    } else {
       form_jsx = (
         <div>
           <Paper  style={style1}>
             <label>参加者数 : {presences.length}</label>
             <div align="right">
               <form onSubmit={this.handleLeave.bind(this)} >
                 <RaisedButton type="submit" primary={true} label="Leave" />
               </form>
             </div>
           </Paper>
           <Paper  style={style1}>
             <form onSubmit={this.handleSubmit.bind(this)}>
               <label>チャット</label>&nbsp;&nbsp;&nbsp;&nbsp;
               <TextField hintText="Chat Text" value = {this.state.inputMessage} onChange = {this.handleInputMessage.bind(this)} />&nbsp;&nbsp;&nbsp;&nbsp;
               <RaisedButton type="submit" primary={true} label="Submit" />
             </form>
             <Divider />
             <br />
             <div>
               {messages}
             </div>
           </Paper>
         </div>
      );
    }

    return (
      <div>
        {form_jsx}
      </div>
    )
  }
}

export default Chat
