/*
  Usage:
  <%= react_component("PageLookupSidebar", {}) %>
*/

import React     from "react"
import PropTypes from "prop-types"
import { makeStyles } from '@material-ui/core/styles';

import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import InboxIcon from '@material-ui/icons/MoveToInbox';
import MailIcon from '@material-ui/icons/Mail';
import Button from '@material-ui/core/Button';
import ListSubheader from '@material-ui/core/ListSubheader';

import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import StarBorder from '@material-ui/icons/StarBorder';
import Collapse from '@material-ui/core/Collapse';

class PageLookupSidebar extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      open:      false,
      loading:   false,
      show_data: false,
      category_open: {}
    };
  }

  loadPage(page_type, page_id) {
    this.setDrawerVisible(true);
    
    // show loading icon

    // make api request

    // hide loading icon

    // load response into list
    this.setState({
      page_data: {
        name: page_type + ' ' + 'Bob',
        categories: [
          {
            id:    1,
            label: 'General',
            fields: [
              {
                label: 'Name',
                value: 'Bob',
                type:  'text'
              },
              {
                label: 'Age',
                value: '55',
                type:  'text'
              }
            ]
          },
          {
            id:    2,
            label: 'Family',
            fields: [
              {
                label: 'Mom',
                value: 'Robin',
                type:  'link',
                link:  ['Character', 534]
              }

            ]
          }
        ]
      }
    });

    console.log("setting show_data = true");
    this.setState({ show_data: true });
    // this.state.show_data = true;
    console.log("show data? " + this.state.show_data);
  };

  setDrawerVisible(open) {
    this.setState({ open: open });
  };

  toggleCategoryOpen(category) {
    this.setState({ category_open: {
      [category]: !this.state.category_open[category]
    }});
  }

  pageData() {
    if (this.state.show_data) {
      return (
        <div
          role="presentation"
        >
          <List
            aria-labelledby="nested-list-subheader"
            subheader={
              <ListSubheader component="div" id="nested-list-subheader">
                Quick-reference
              </ListSubheader>
            }
          >
            <ListItem button>
              <ListItemText primary={this.state.page_data.name} />
            </ListItem>

            {this.state.page_data.categories.map((category) => (
              <React.Fragment>
                <ListItem button onClick={() => this.toggleCategoryOpen(category.label)}>
                  <ListItemIcon>
                    <InboxIcon />
                  </ListItemIcon>
                  <ListItemText primary={category.label} />
                  {!!this.state.category_open[category.label] ? <ExpandLess /> : <ExpandMore />}
                </ListItem>
                <Collapse in={!!this.state.category_open[category.label]} timeout="auto" unmountOnExit>
                  <List component="div" disablePadding>
                    {category.fields.map((field) => (
                      <ListItem button={field.type == 'link'}>
                        {field.type == 'text' && 
                          <ListItemText primary={field.label} secondary={field.value} />
                        }
                        {field.type == 'link' &&
                          <ListItemText primary={field.label} secondary={field.value} />
                        }
                      </ListItem>
                    ))}
                  </List>
                </Collapse>
              </React.Fragment>
            ))}
          </List>
        </div>
      );

    } else { // No data to show yet
      return (
        <div
          role="presentation"
        >
          <List
            aria-labelledby="nested-list-subheader"
            subheader={
              <ListSubheader component="div" id="nested-list-subheader">
                Quick-reference
              </ListSubheader>
            }
          >
            <ListItem>
              <ListItemText primary="Loading data..." />
            </ListItem>
          </List>
        </div>
      );
    }
  };

  render () {
    return (
      <React.Fragment>
        <Button onClick={() => this.loadPage('Character', 1) }>
          toggle drawer
        </Button>
        <Drawer anchor='right' 
                open={this.state['open']}
                onClose={() => this.setDrawerVisible(false)}>
          {this.pageData()}
        </Drawer>
      </React.Fragment>
    )
  }
}

// PrivacyToggle.propTypes = {
//   content:       PropTypes.exact({
//     id:             PropTypes.number.isRequired,
//     name:           PropTypes.string.isRequired,
//     page_type:      PropTypes.string.isRequired,
//     privacy:        PropTypes.string.isRequired
//   }).isRequired,
//   content_icon:  PropTypes.string.isRequired,
//   content_color: PropTypes.string.isRequired,
//   submit_path:   PropTypes.string.isRequired
// };

export default PageLookupSidebar;
