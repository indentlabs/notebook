/*
  Usage:
  <%= react_component("PageCollectionCreationForm", {}) %>
*/

import React     from "react"
import PropTypes from "prop-types"

import Stepper from '@material-ui/core/Stepper';
import Step from '@material-ui/core/Step';
import StepLabel from '@material-ui/core/StepLabel';
import StepContent from '@material-ui/core/StepContent';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';

class PageCollectionCreationForm extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      active_step: 0
    }

    this.handleNext  = this.handleNext.bind(this);
    this.handleBack  = this.handleBack.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleNext() {
    this.setState({ active_step: this.state.active_step + 1 });
  };

  handleBack() {
    this.setState({ active_step: this.state.active_step - 1 });
  };

  handleReset() {
    this.setState({ active_step: 0 });
  };

  classIcon(class_name) {
    return window.ContentTypeData[class_name].icon;
  }

  classColor(class_name) {
    return window.ContentTypeData[class_name].color;
  }

  steps() {
    return ['Basic information', 'Acceptable pages', 'Privacy settings'];
  }
  
  getStepContent(step) {
    switch (step) {
      case 0:
        return(
          <div className="spaced-paragraphs">
            <Typography>
               Let's get started with some basic information.
            </Typography>
            <div className="input-field">
              <label>Collection title</label>
              <input type="text" name="page_collection[title]" />
            </div>
            <div className="input-field">
              <label>Subtitle <span className="grey-text">(optional)</span></label>
              <input type="text" name="page_collection[subtitle]" />
            </div>
            <div className="input-field">
              <label>Description</label>
              <input type="text" name="page_collection[description]" />
            </div>
            <div>
              <p className="grey-text">Header image (optional)</p>
              <div className="file-field input-field">
                <div className="blue btn">
                  <span>Upload</span>
                  <input type="file" name="page_collection[header_image]" />
                </div>
                <div className="file-path-wrapper">
                  <input className="file-path validate" type="text" placeholder="Upload an image" />
                </div>
              </div>
              <div className="help-text">
                Supported file types: .png, .jpg, .jpeg, .gif
              </div>
            </div>
            <br /><br />
          </div>
        );
      case 1:
        return (
          <div>
            <Typography>
              Please check the types of pages you would like to allow in this collection. A small number of page types is recommended.
            </Typography>
            <div className="row">
              {this.props.all_content_types.map(function(type) {
                return(
                  <p className="col s12 m6 l4">
                    <label>
                      <input name="page_collection[page_types[Universe]]" type="hidden" value="0" />
                      <input type="checkbox" value="1" name="page_collection[page_types[Universe]]" />
                      <span className="purple-text">
                        <i className="material-icons left">language</i>
                        Universes
                      </span>
                    </label>
                  </p>
                );
              })}
              
            </div>
          </div>
        );
      case 2:
        return (
          <div>
            <Typography>
              By default, all Collections are private. However, you can choose to make your Collection public at any time, and you can also choose to
              accept submissions from other users!
            </Typography>
          </div>
        );

      default:
        return 'Unknown step';
    }
  }

  render () {
    return (
      <div className='card-panel'>
        <Stepper activeStep={this.state.active_step} orientation="vertical">
          {this.steps().map((label, index) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
              <StepContent>
                {this.getStepContent(index)}
                <div>
                  <div>
                    <Button
                      disabled={this.state.active_step === 0}
                      onClick={this.handleBack}
                    >
                      Back
                    </Button>
                    <Button
                      variant="contained"
                      color="primary"
                      onClick={this.handleNext}
                    >
                      {this.state.active_step === this.steps().length - 1 ? 'Finish' : 'Next'}
                    </Button>
                  </div>
                </div>
              </StepContent>
            </Step>
          ))}
        </Stepper>
        {this.state.active_step === this.steps().length && (
          <Paper square elevation={0}>
            <Typography>All steps completed - you're finished!</Typography>
            <Button onClick={this.handleReset}>
              Reset
            </Button>
          </Paper>
        )}
      </div>
    );
  }
}

PageCollectionCreationForm.propTypes = {
  document_id: PropTypes.number
};

export default PageCollectionCreationForm;