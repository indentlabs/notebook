/*
  Usage:
  <%=
    react_component("DocumentEntityLinkModal", {
      form_path:    link_entity_documents_path,
      content_list: @current_user_content
    })
  %>
*/

import React     from "react"
import PropTypes from "prop-types"
import { makeStyles } from '@material-ui/core/styles';

import CheckIcon from '@material-ui/icons/Check';
import ToggleButton from '@material-ui/lab/ToggleButton';

var pluralize = require('pluralize');

import axios from 'axios';

class DocumentEntityLinkModal extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      selected: false
    };
  }

  componentDidMount() {
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

  classIcon(class_name) {
    return window.ContentTypeData[class_name].icon;
  }

  classColor(class_name) {
    return window.ContentTypeData[class_name].color;
  }

  toggleEntityLink(entity) {
    console.log('linking');
    console.log(entity);
  }

  render () {
    return (
      <div id="entity-link-modal" className="modal">
        <div className="modal-content">
          <h4>Add a quick reference</h4>
          <p>
            Select the page below you'd like to link to this document. 
            You can then click it at any time to quickly view that page without leaving your document.
          </p>
          
          <form action={this.props.form_path} acceptCharset="UTF-8" method="post">
            <input name="utf8" type="hidden" value="✓" />
            <input value="8" type="hidden" name="document_id" />
            <input value="-1" type="hidden" name="document_analysis_id" />
            <input value="-1" type="hidden" name="document_entity_id" />
            <input type="hidden" name="entity_type" />
            <input type="hidden" name="entity_id" />

            {Object.keys(this.props.content_list).map((content_type, i) => {
              if (content_type !== "Document") {
                var content_list = this.props.content_list[content_type];
                return(
                  <React.Fragment key={i}>
                    <h5>{ pluralize(content_type) }</h5>
                    <ul className="collection">
                      {content_list.map((content, j) => {
                        return(
                          <React.Fragment>
                            {/*
                            <ToggleButton
                              value="check"
                              selected={false}
                              onChange={() => {
                                this.toggleEntityLink(content);
                              }}
                            >
                              { content.name || "Untitled" }
                            </ToggleButton>
                            */}

                            <a href="#" className={this.classColor(content_type) + "-text js-link-entity-selection"} data-id={content.id} data-type={content_type} key={j}>
                              <li className="collection-item hoverable">
                                <i className="material-icons left">{ this.classIcon(content_type) }</i>
                                {content.name || "Untitled"}
                                <span className="secondary-content">
                                  <i className="material-icons">link</i>
                                </span>
                              </li>
                            </a>
                          </React.Fragment>
                        );
                      })}
                    </ul>
                  </React.Fragment>
                );
              }
            })}
          </form>
        </div>
        <div className="modal-footer">
          <a href="#!" className="modal-close waves-effect waves-green btn-flat">Cancel</a>
        </div>
      </div>
    );
  }
}

DocumentEntityLinkModal.propTypes = {
  form_path:    PropTypes.string.isRequired,
  content_list: PropTypes.object.isRequired
};

export default DocumentEntityLinkModal;
