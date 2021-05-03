/*
  Usage:
  <%= 
    react_component("PrivacyToggle", {
      content:       content.attributes.slice('id', 'name', 'page_type', 'privacy'),
      content_icon:  content.class.icon,
      content_color: content.class.color,
      submit_path:   polymorphic_path(content),
      csrf_token:    form_authenticity_token
    })
  %>
*/

import React     from "react"
import PropTypes from "prop-types"

import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';

import axios from 'axios';

class PrivacyToggle extends React.Component {
  constructor(props) {
    super(props);
    
    var initial_privacy = this.props.content.privacy;
    if (initial_privacy == null) {
      // Default null privacy settings to private
      initial_privacy = 'private';
    }

    this.state = {
      privacy: initial_privacy
    };

    // console.log('Privacy: ' + this.state.privacy);
    axios.defaults.headers.common['X-CSRF-TOKEN'] = this.props.csrf_token;
  }

  async autosave() {
    var new_privacy_setting = (this.state.privacy == 'public' ? 'private' : 'public');
    // console.log('changing privacy to --> ' + new_privacy_setting);

    await axios.patch(
      this.props.submit_path,
      { 
        [this.props.content.page_type.toLowerCase()]: {
          privacy: new_privacy_setting
        } 
      },
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Accept':       'application/json'
        }
      }
    );

    this.setState({ privacy: new_privacy_setting })
  }

  render () {
    return (
        <FormControl component="fieldset">
          <FormLabel component="legend">
            <i className={`material-icons ${this.props.content_color}-text left`}>
              {this.props.content_icon}
            </i>
            {this.props.content.name}'s privacy:
          </FormLabel>
          <RadioGroup 
            aria-label="privacy" 
            name="privacy" 
            value={this.state.privacy}
            onChange={() => this.autosave()}
          >
            <FormControlLabel
              value="private"
              control={<Radio color="primary" />}
              label="Private (default)"
              labelPlacement="start"
              className="black-text"
              
            />
            <FormControlLabel
              value="public"
              control={<Radio color="primary" />}
              label="Public"
              labelPlacement="start"
              className="black-text"
            />
            {/*
            <FormControlLabel
              value="searchable"
              control={<Radio color="primary" />}
              label="Discoverable"
              labelPlacement="start"
            />
            */}
          </RadioGroup>
          {/*
          <FormHelperText>
            You can change this page's privacy setting at any time.
          </FormHelperText>
          */}
        </FormControl>
    );
  }
}

PrivacyToggle.propTypes = {
  content:       PropTypes.exact({
    id:             PropTypes.number.isRequired,
    name:           PropTypes.string.isRequired,
    page_type:      PropTypes.string.isRequired,
    privacy:        PropTypes.string
  }).isRequired,
  content_icon:  PropTypes.string.isRequired,
  content_color: PropTypes.string.isRequired,
  submit_path:   PropTypes.string.isRequired
};

export default PrivacyToggle;
