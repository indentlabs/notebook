import React from "react"
import PropTypes from "prop-types"
class Footer extends React.Component {
  render () {
    return (
      <footer class="stealth-page-footer grey-text">
        <div class="container center">
          <div class="row">
            <div class="col s12">
              <div class="grey-text">
                <a href="https://www.twitter.com/indentlabs" class="grey-text" target="_blank"><i class="fa fa-twitter blue-text"></i> Twitter</a> &middot; 
                <a href="https://www.facebook.com/Notebookai-556092274722663/" class="grey-text" target="_blank"><i class="fa fa-facebook blue-text"></i> Facebook</a> &middot; 
                <a href="https://github.com/indentlabs/notebook" class="grey-text" target="_blank"><i class="fa fa-github black-text"></i> GitHub</a>
              </div>
            </div>
          </div>
        </div>
        <div class="footer-copyright center">
          <div class="container">
            Notebook.ai © 2016-2020 <a href='http://www.indentlabs.com' class='gre-text'>Indent Labs, LLC</a>
          </div>
        </div>
      </footer>
    );
  }
}

export default Footer;
