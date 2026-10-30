/*
  DEPRECATED: This component uses MaterializeCSS and appears to be unused.
  All document views have been migrated to TailwindCSS.
  
  Original Usage:
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

import DocumentEntityLinkModal from './DocumentEntityLinkModal.js';
import PageLookupSidebar from './PageLookupSidebar.js';

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

          {Object.keys(this.state.linked_entities).length === 0 && (
            <li>
              <div className="card-panel teal lighten-5 black-text" style={{lineHeight: '1.5em'}}>
                You can link your notebook pages directly to this document.
                <br /><br />
                When you do, you'll be able to quickly reference them from this menu without needing to navigate away from your document.
                You'll also be able to see a list of all the documents a page is linked to when viewing that page.
              </div>
            </li>
          )}

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
                                <span className='js-load-page-name' data-klass={entity_type} data-id={entity.entity_id}>
                                  <span className='name-container'>{ entity.text }</span>
                                </span>
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
        <DocumentEntityLinkModal form_path={this.props.link_form_path} content_list={this.props.user_content} document_id={this.props.document_id} />
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
