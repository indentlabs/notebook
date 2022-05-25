/*
  Usage:
  <%= react_component("PageLookupSidebar", {document_id: @document.id}) %>
*/

import React     from "react"
import PropTypes from "prop-types"

import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListSubheader from '@material-ui/core/ListSubheader';
import Chip from '@material-ui/core/Chip';
import SimpleFormat from './SimpleFormat.js';

import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Collapse from '@material-ui/core/Collapse';

var pluralize = require('pluralize');

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

    window.page_lookup_cache = {};
  }

  classIcon(class_name) {
    return window.ContentTypeData[class_name].icon;
  }

  classColor(class_name) {
    return window.ContentTypeData[class_name].color;
  }

  async loadPage(page_type, page_id) {
    this.setDrawerVisible(true);
    this.setState({
      show_data:     false,
      category_open: {}
    });

    if ((page_type + '-' + page_id) in window.page_lookup_cache) {
      this.setState({ 
        page_data: window.page_lookup_cache[page_type + '-' + page_id],
        show_data: true,
        page_type: page_type,
        page_id:   page_id
      });

    } else {
      // make new api request
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
        // cache response
        window.page_lookup_cache[page_type + '-' + page_id] = response.data;

        // load response into list
        this.setState({ 
          page_data: response.data,
          show_data: !response.data.hasOwnProperty('error'),
          page_type: page_type,
          page_id:   page_id
        });

      }).catch(err => {
        console.log(err);
        this.setDrawerVisible(false);

        return null;
      });
    }
  };

  content_page_view_path(content_type, content_id) {
    return '/plan/' + pluralize(content_type.toLowerCase()) + '/' + content_id;
  };

  content_page_edit_path(content_type, content_id) {
    return '/plan/' + pluralize(content_type.toLowerCase()) + '/' + content_id + '/edit';
  };

  content_page_tag_path(content_type, tag_slug) {
    return '/plan/' + pluralize(content_type.toLowerCase()) + '/tagged/' + tag_slug;
  }

  link_destroy_path(document_id, page_type, page_id) {
    return '/documents/' + document_id + '/unlink/' + page_type + '/' + page_id;
  }

  setDrawerVisible(open) {
    this.setState({ open: open });
  };

  toggleCategoryOpen(category) {
    this.setState({ category_open: {
      [category]: !this.state.category_open[category]
    }});
  };

  fieldData(field) {
    switch (field.type) {
      case "name":
      case "text_area":
        // console.log(field.value);
        return (
          <React.Fragment key={field.id}>
            <ListSubheader component="div" style={{lineHeight: '1.5em'}}>
              {field.label}
            </ListSubheader>
            <ListItem>
              <SimpleFormat text={ field.value } />
            </ListItem>
          </React.Fragment>
        );
      
      case "link":
        return(
          <React.Fragment key={field.id}>
            <ListSubheader component="div" style={{lineHeight: '1.5em'}}>
              { pluralize(field.label, field.value.length, true) }
            </ListSubheader>
            {field.value.map((link) => (
              <ListItem button key={link.id} onClick={() => { this.loadPage(link.page_type, link.id); }}>
                <ListItemText primary={
                  <div>
                    <i className={this.classColor(link.page_type) + '-text material-icons left'}>
                      {this.classIcon(link.page_type)}
                    </i>
                    { link.name }
                  </div>
                } />
              </ListItem>
            ))}
          </React.Fragment>
        );
      
      case "universe":
        // console.log(field.value);
        return(
          <React.Fragment key={field.value.id}>
            <ListSubheader component="div" style={{lineHeight: '1.5em'}}>
              Universe
            </ListSubheader>
            <ListItem button onClick={() => { this.loadPage('Universe', field.id); }}>
              <ListItemText primary={
                <div>
                  <i className={this.classColor('Universe') + '-text material-icons left'}>
                    {this.classIcon('Universe')}
                  </i>
                  { this.state.page_data.universe.name }
                </div>
              } />
            </ListItem>
          </React.Fragment>
        );

      case "tags":
        return(
          <React.Fragment>
            <ListSubheader component="div" style={{lineHeight: '1.5em'}}>
              Tags
            </ListSubheader>
            <ListItem>
              {field.value.map((tag) => {
                return(
                  <Chip
                    id={'tag-' + tag.tag}
                    variant="outlined"
                    size="small"
                    label={tag.tag}
                    component="a"
                    href={this.content_page_tag_path(this.state.page_type, tag.slug)}
                    style={{marginRight: '0.25em'}}
                    clickable
                  />
                );
              })}
            </ListItem>
          </React.Fragment>
        );
      
      case "TimelineEvent":
        return(
          <React.Fragment key={field.id}>
            <ListSubheader component="div" style={{lineHeight: '1.5em'}}>
              <div className='right'>
                <i className='material-icons right'>
                  schedule
                </i>
                { field.time_label }
              </div>
              {field.label}
            </ListSubheader>
            <ListItem>
              <SimpleFormat text={ field.description } />
            </ListItem>
            <Divider></Divider>
          </React.Fragment>
        )
      
      default:
        return(
          <div>error loading {field.type}: {field.label}</div>
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
              <h5>
                <i className="right">&nbsp;</i>
                <i className={"material-icons right " + this.classColor(this.state.page_type) + '-text'}>
                  {this.classIcon(this.state.page_type)}
                </i>
                &nbsp;&nbsp;&nbsp;{this.state.page_data.name}
              </h5>
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
                  <i className="material-icons left">
                    { category.icon }
                  </i>
                  <ListItemText primary={ category.label } />
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
            <Divider />
            <a href={this.content_page_view_path(this.state.page_type, this.state.page_id)}>
              <ListItem button>
                <i className={"blue-text material-icons left"}>
                  { this.classIcon(this.state.page_type) }
                </i>
                <ListItemText primary={"View this " + this.state.page_type} />
              </ListItem>
            </a>
            <a href={this.content_page_edit_path(this.state.page_type, this.state.page_id)}>
              <ListItem button>
                <i className={"green-text material-icons left"}>
                  { this.classIcon(this.state.page_type) }
                </i>
                <ListItemText primary={"Edit this " + this.state.page_type} />
              </ListItem>
            </a>
            <a href={this.link_destroy_path(this.props.document_id, this.state.page_type, this.state.page_id)}>
              <ListItem button>
                <i className={"red-text material-icons left"}>
                  remove
                </i>
                <ListItemText primary={"Remove this link"} />
              </ListItem>
            </a>
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
              <ListItemText primary="Loading page..." />
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
      <Drawer anchor='right'
              open={this.state['open']}
              onClose={() => this.setDrawerVisible(false)}
      >
        {this.pageData()}
      </Drawer>
    )
  }
}

PageLookupSidebar.propTypes = {
  document_id: PropTypes.number
};

export default PageLookupSidebar;
