/*
  Usage:
  <%=
    react_component("DocumentEntityLinkModal", {})
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

var pluralize = require('pluralize');

import axios from 'axios';

class DocumentEntityLinkModal extends React.Component {

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    console.log('initializing linker');

    $('.js-link-entity').click(function () {
      $('#entity-link-modal').modal('open');
      return false;
    });

    $('.js-link-entity-selection').click(function () {
      var entity = $(this);
      var form   = $(this).closest('form');

      form.find('input[name=entity_id]').val(entity.data('id'));
      form.find('input[name=entity_type]').val(entity.data('type'));
      form.submit();
    });
  }

  render () {
    return (
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
                          <li key={j}>
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
            Add an entity
          </a>
        </li>
      </ul>
    );
  }
}

// DocumentEntityLinkModal.propTypes = {
//  linked_entities: PropTypes.object.isRequired
// };

export default DocumentEntityLinkModal;
