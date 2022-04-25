import "../css/app.css"

import "phoenix_html";
import React from "react";
import ReactDOM from "react-dom";
import lightBaseTheme from 'material-ui/styles/baseThemes/lightBaseTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';

import Chat from "./Chat";

class App extends React.Component {
  render() {
    return (
      <Chat />
    )
  }
}

const target = document.getElementById('app');
const node =(
  <MuiThemeProvider muiTheme={getMuiTheme(lightBaseTheme)}>
    <App />
  </MuiThemeProvider>
);

ReactDOM.render( node, target )
