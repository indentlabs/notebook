/*
  Usage:
  <%=
    react_component("DocumentEntitiesSidebar", {
      document_id:     3,
      linked_entities: { 
        'Character' => [], 
        ...
      }
    })
  %>
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

import DocumentEntityLinkModal from './DocumentEntityLinkModal.js';
import PageLookupSidebar from './PageLookupSidebar.js';

import axios from 'axios';

var pluralize = require('pluralize');

class DocumentEntitiesSidebar extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      linked_entities: this.props.linked_entities
    };
  }

  classIcon(class_name) {
    return window.ContentTypeData[class_name].icon;
  }

  classColor(class_name) {
    return window.ContentTypeData[class_name].color;
  }

  componentDidMount() {
    // We have a setTimeout call here because materializecss's initializer isn't playing well with
    // the component lifecycle. Calling sidenav() in componentDidMount() produces several graphical
    // errors (sliding in from the center of the screen, overlapping the doc editor when closed, etc)
    // so we're just doing this for now instead. 
    //
    // Implications of this hack: for the first second after mounting this component, a user opening
    // this component will have it open on the left side of the screen instead of the right side. Then,
    // when this timeout triggers, the sidebar will close. Reopening it will open it on the right side
    // of the screen.
    //
    // It's also possible some slow computers/internets might have issues that would require longer than
    // one second of waiting, but in that case we just default to opening this sidenav on the left side
    // of the screen (default sidenav behavior) instead of the right side.
    setTimeout(function () {
      $('#document-entities-right').sidenav({
        closeOnClick: true,
        edge:         'right',
        draggable:    false
      });
    }, 1000);
  }

  lookupPage(content_type, content_id) {
    // console.log('loading page: ' + content_type + ' ' + content_id);
    this.refs.PageLookupSidebar.loadPage(content_type, content_id);
  }

  render () {
    // console.log(this.state.linked_entities);
    return (
      <React.Fragment>
        <ul id="document-entities-right" className="sidenav">
          <li className="teal">
            <a href="#" className="logo-container white-text">
              <i className="material-icons white-text right">
                book
              </i>
              In this document...
            </a>
          </li>
          <li className="no-padding">
            <ul className="collapsible collapsible-accordion">
              {Object.keys(this.state.linked_entities).map((entity_type, i) => {
                return (
                  <li className="bold waves-effect" key={i}>
                    <a className="collapsible-header" tabIndex="0">
                      {pluralize(entity_type, this.state.linked_entities[entity_type].length, true)}
                      <i className="material-icons chevron">chevron_right</i>
                    </a>
                    <div className="collapsible-body">
                      <ul>
                        {this.state.linked_entities[entity_type].map((entity, j) => {
                          return(
                            <li key={j} onClick={() => { this.lookupPage(entity_type, entity.entity_id) }}>
                              <a href="#">
                                <i className={"material-icons left " + this.classColor(entity_type) + "-text"}>
                                  { this.classIcon(entity_type) }
                                </i>
                                { entity.text }
                              </a>
                            </li>
                          );
                        })}
                      </ul>
                    </div>
                  </li>
                );
              })}
            </ul>
          </li>
          <li className="divider"></li>
          <li>
            <a href="#"
                className="entity-trigger orange-text text-darken-3 js-link-entity">
              <i className="material-icons small orange-text text-darken-3 left">add</i>
              Link a page
            </a>
          </li>
        </ul>
        <DocumentEntityLinkModal form_path={this.props.link_form_path} content_list={this.props.user_content} />
        <PageLookupSidebar ref="PageLookupSidebar" document_id={this.props.document_id} />
      </React.Fragment>
    );
  }
}

DocumentEntitiesSidebar.propTypes = {
 linked_entities: PropTypes.object.isRequired,
 link_form_path:  PropTypes.string.isRequired
};

export default DocumentEntitiesSidebar;
