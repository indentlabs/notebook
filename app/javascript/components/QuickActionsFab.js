import React from "react"
import PropTypes from "prop-types"

import SpeedDial from '@material-ui/lab/SpeedDial';
import SpeedDialIcon from '@material-ui/lab/SpeedDialIcon';
import SpeedDialAction from '@material-ui/lab/SpeedDialAction';

class QuickActionsFab extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }

  handle_close() {
    this.setState({ open: false });
  }

  handle_open() {
    this.setState({ open: true });
  }

  handle_click(route) {
    window.location = route;
    this.handle_close();
  }

  render () {
    return (        
      <SpeedDial
        ariaLabel="SpeedDial example"
        icon={<SpeedDialIcon />}
        onClose={() => this.handle_close()}
        onOpen={() => this.handle_open()}
        open={this.state.open}
        direction='left'
        className="speed-dial-fab"
      >
        {this.props.actions.map(action => (
          <SpeedDialAction
            key={action.name}
            icon={<i className={`material-icons ${action.color}-text`}>{action.icon}</i>}
            tooltipTitle={action.name}
            placement="top"
            interactive={true}
            arrow={true}
            onClick={() => this.handle_click(action.route)}
          />
        ))}
      </SpeedDial>
    );
  }
}

QuickActionsFab.propTypes = {
  actions: PropTypes.arrayOf(PropTypes.exact({
    name:  PropTypes.string.isRequired,
    icon:  PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
    route: PropTypes.string.isRequired
  })),
};

export default QuickActionsFab;