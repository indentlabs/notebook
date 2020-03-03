import React from 'react';
import Footer from '../app/javascript/components/Footer';
import Button from '../app/javascript/components/Button';

export default {
  title:    'Buttons',
  component: Button,
};

export const Show = () => 
  <React.Fragment>
    <Button color="primary" variant="contained" label="Button text" startIcon="dashboard" />
  </React.Fragment>;