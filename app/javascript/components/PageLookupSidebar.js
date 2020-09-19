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
import Button from '@material-ui/core/Button';
import ListSubheader from '@material-ui/core/ListSubheader';

import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import StarBorder from '@material-ui/icons/StarBorder';
import HelpIcon from '@material-ui/icons/Help';
import Collapse from '@material-ui/core/Collapse';

import axios from 'axios';

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

  async loadPage(page_type, page_id) {
    this.setDrawerVisible(true);
    this.setState({ show_data: false });

    // make api request
    await axios.get(
      "/api/v1/" + page_type.toLowerCase() + "/" + page_id
        + '?application_token=4756de490e82956dc6329e6650aaec664e27ccd27e153e2f'
        + '&authorization_token=167bb93139303904cf67f6480a29e71c9f1eaf7a28e902e1',
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Accept':       'application/json'
        }
      }
    ).then(response => {
      console.log("get request");
      console.log(response.data);

      // load response into list
      this.setState({ 
        page_data: response.data,
        show_data: !response.data.hasOwnProperty('error'),
        page_type: page_type
      });

    }).catch(err => {
      console.log(err);
      return null;
    });

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

  fieldData(field) {
    switch (field.type) {
      case "name":
      case "text_area":
        return (
          <ListItem key={field.id}>
            <ListItemText primary={field.label} secondary={field.value} />
          </ListItem>
        );
      
      case "link":
        return(
          <React.Fragment key={field.id}>
            <ListSubheader component="div">
              {field.label}
            </ListSubheader>
            {field.value.map((link) => (
              <ListItem button key={link.id}>
                <ListItemText primary={link.name} />
              </ListItem>
            ))}
          </React.Fragment>
        );
      
      default:
        return(
          <div>error loading {field.label}</div>
        );
    }
  }

  pageData() {
    if (this.state.show_data) {
      return (
        <div
          role="presentation"
        >
          <List
            subheader={
              <h5>&nbsp;&nbsp;&nbsp;{this.state.page_data.name}</h5>
            }
            id="page-lookup-list"
          >
            <Divider></Divider>
            <ListSubheader component="div">
              Quick-reference
            </ListSubheader>

            {this.state.page_data.categories.map((category) => (
              <React.Fragment key={category.id}>
                <ListItem button onClick={() => this.toggleCategoryOpen(category.label)}>
                  <ListItemIcon>
                    <HelpIcon />
                  </ListItemIcon>
                  <ListItemText primary={category.label} />
                  {!!this.state.category_open[category.label] ? <ExpandLess /> : <ExpandMore />}
                </ListItem>
                <Collapse in={!!this.state.category_open[category.label]} timeout="auto" unmountOnExit>
                  <List component="div" disablePadding>
                    {category.fields.map((field) => (
                      this.fieldData(field)
                    ))}
                  </List>
                </Collapse>
              </React.Fragment>
            ))}
            <Divider></Divider>
            <ListItem button>
              <ListItemIcon>
                <HelpIcon />
                <ListItemText primary={"View this " + this.state.page_type} />
              </ListItemIcon>
            </ListItem>
            <ListItem button>
              <ListItemIcon>
                <HelpIcon />
                <ListItemText primary={"Edit this " + this.state.page_type} />
              </ListItemIcon>
            </ListItem>
          </List>
        </div>
      );
      // also add divider + view/edit links

    } else { // No data to show yet
      return (
        <div
          role="presentation"
        >
          <List
            subheader={
              <ListSubheader component="div">
                Quick-reference
              </ListSubheader>
            }
          >
            <ListItem>
              <ListItemText primary="Loading data..." />
            </ListItem>
          </List>
          <div className="center">
            <div className="preloader-wrapper big active">
              <div className="spinner-layer spinner-blue">
                <div className="circle-clipper left">
                  <div className="circle"></div>
                </div><div className="gap-patch">
                  <div className="circle"></div>
                </div><div className="circle-clipper right">
                  <div className="circle"></div>
                </div>
              </div>

              <div className="spinner-layer spinner-red">
                <div className="circle-clipper left">
                  <div className="circle"></div>
                </div><div className="gap-patch">
                  <div className="circle"></div>
                </div><div className="circle-clipper right">
                  <div className="circle"></div>
                </div>
              </div>

              <div className="spinner-layer spinner-yellow">
                <div className="circle-clipper left">
                  <div className="circle"></div>
                </div><div className="gap-patch">
                  <div className="circle"></div>
                </div><div className="circle-clipper right">
                  <div className="circle"></div>
                </div>
              </div>

              <div className="spinner-layer spinner-green">
                <div className="circle-clipper left">
                  <div className="circle"></div>
                </div><div className="gap-patch">
                  <div className="circle"></div>
                </div><div className="circle-clipper right">
                  <div className="circle"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }
  };

  render () {
    return (
      <React.Fragment>
        {/*
        <Button onClick={() => this.loadPage('Character', 1) }>
          toggle drawer
        </Button>
        */}
        <Drawer anchor='right' 
                open={this.state['open']}
                onClose={() => this.setDrawerVisible(false)}
        >
          {this.pageData()}
        </Drawer>
      </React.Fragment>
    )
  }
}

// PageLookupSidebar.propTypes = {
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
