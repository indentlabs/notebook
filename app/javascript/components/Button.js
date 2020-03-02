import React from "react"
import PropTypes from "prop-types"

import MaterialButton from '@material-ui/core/Button';
import IconButton     from '@material-ui/core/IconButton';
import Icon           from '@material-ui/core/Icon';

class Button extends React.Component {
  render () {
    return (
      <MaterialButton 
        color={this.props.color} 
        variant={this.props.variant} 
        disabled={this.props.disabled}
        size={this.props.size}
        disableElevation={!this.props.elevated}
        startIcon={<Icon>this.props.startIcon</Icon>}
        endIcon={this.props.endIcon}
      >
        {this.props.label}
      </MaterialButton>
    );
  }
}

Button.propTypes = {
  color:     PropTypes.string,
  variant:   PropTypes.string,
  size:      PropTypes.string,
  disabled:  PropTypes.bool,
  elevated:  PropTypes.bool,
  startIcon: PropTypes.string,
  endIcon:   PropTypes.string,
  href:      PropTypes.string,
  label:     PropTypes.string,
};

export default Button;
