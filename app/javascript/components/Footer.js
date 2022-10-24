import React from "react"

class Footer extends React.Component {
  render () {
    return (
      <footer className="grey-text no-print">
        <div className="container center">
          <div className="row">
            <div className="col s12">
              <div>
                <a href="https://www.twitter.com/indentlabs" target="_blank">
                  <i className="fa fa-twitter blue-text"></i> Twitter
                </a>
                &nbsp;&middot;&nbsp; 
                <a href="https://www.facebook.com/Notebookai-556092274722663/" target="_blank">
                  <i className="fa fa-facebook blue-text"></i> Facebook
                </a>
                &nbsp;&middot;&nbsp; 
                <a href="https://github.com/indentlabs/notebook" target="_blank">
                  <i className="fa fa-github black-text"></i> GitHub
                </a>
                &nbsp;&middot;&nbsp; 
                <a href="https://github.com/indentlabs/notebook" target="_blank">
                  <i className="fa fa-brands fa-discord blue-text"></i> Discord
                </a>
              </div>
            </div>

            Notebook.ai © 2016-2022 <a href='http://www.indentlabs.com' className='grey-text'>
              Indent Labs, LLC
            </a>
          </div>
        </div>
      </footer>
    );
  }
}

export default Footer;
