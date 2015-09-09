// gum.js 1.0
// (c) 2015 Artur Augusto Martins
// gum.js is freely distributable under the GPL v2 license.
// For all details and documentation:
// https://github.com/arturaugusto/gumjs
(function() {
  // Gamma related functions borrowed from: https://github.com/substack/gamma.js
  var g = 7;
  var p = [
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7
  ];

  var g_ln = 607/128;
  var p_ln = [
    0.99999999999999709182,
    57.156235665862923517,
    -59.597960355475491248,
    14.136097974741747174,
    -0.49191381609762019978,
    0.33994649984811888699e-4,
    0.46523628927048575665e-4,
    -0.98374475304879564677e-4,
    0.15808870322491248884e-3,
    -0.21026444172410488319e-3,
    0.21743961811521264320e-3,
    -0.16431810653676389022e-3,
    0.84418223983852743293e-4,
    -0.26190838401581408670e-4,
    0.36899182659531622704e-5
  ];
  // Spouge approximation (suitable for large arguments)
  function lngamma(z) {

    if(z < 0) return Number('0/0');
    var x = p_ln[0];
    for(var i = p_ln.length - 1; i > 0; --i) x += p_ln[i] / (z + i);
    var t = z + g_ln + 0.5;
    return .5*Math.log(2*Math.PI)+(z+.5)*Math.log(t)-t+Math.log(x)-Math.log(z);
  }

  function gamma (z) {
    if (z < 0.5) {
      return Math.PI / (Math.sin(Math.PI * z) * gamma(1 - z));
    }
    else if(z > 100) return Math.exp(lngamma(z));
    else {
      z -= 1;
      var x = p[0];
      for (var i = 1; i < g + 2; i++) {
        x += p[i] / (z + i);
      }
      var t = z + g + 0.5;

      return Math.sqrt(2 * Math.PI)
        * Math.pow(t, z + 0.5)
        * Math.exp(-t)
        * x
      ;
    }
  };

  // End gamma functions

  // Create a sequence array
  var seq = function(start, end, step) {
    var i, res, _i;
    res = [];
    for (i = _i = start; step > 0 ? _i <= end : _i >= end; i = _i += step) {
      res.push(i);
    }
    return res;
  };

  // Sum array
  var sum = function(arr){
    var res = 0;
    for (var i = arr.length - 1; i >= 0; i--) {
      res += parseFloat(arr[i]);
    };
    return(res);
  }

  // take a array and sum v to all itens, returning new array
  var inc_arr = function(arr, v){
    var res = [];
    for (var i = 0; i < arr.length; i++) res.push(arr[i] + v);
    return res;
  }

  var sd = function(array, mean){
    var dev = array.map(function(itm){
      return (parseFloat(itm)-mean)*(parseFloat(itm)-mean); 
    });
    return Math.sqrt(dev.reduce(function(a, b){ return a+b; })/array.length);
  }

  // Get samples from function f at points from array arr
  var sampler = function(f, arr) {
    return arr.map(function(_x) {
      return f.call(void 0, _x);
    });
  };

  // Trapezoidal integration method.
  // translated from R: http://www.r-bloggers.com/trapezoidal-integration-conceptual-foundations-and-a-statistical-application-in-r/
  var trapezoidal = function(f, t_start, t_end, h){
    var x = seq(t_start, t_end, h);
    var y = sampler(f, x);
    var n = y.length;
    var sum_y_samples = sum(y);
    var sum_y = sum_y_samples - (y[0] + y[n-1])/2;
    var integral;
    var integral = sum_y*h;
    return(integral);
  }

  // T student distribution probabilities, at point t with v degrees of freedon
  function tdist(v, t){
    return gamma((v+1)/2) / (Math.sqrt(v * Math.PI) * gamma(v/2)) * Math.pow((1 + Math.pow(t, 2)/v), -((v+1)/2));
  }

  // Get coverage factor by
  // integrating tdist with v deg freedon until reach cl
  function invt(v, cl){
    if(cl >= 1 || cl <= 0){
      console.error("confidence level must be < 1 and > 0");
    }
    var v_max = 300;
    // limit deg freedom
    if(v > v_max){
      v = v_max;
    }
    var k = 0;
    var k_i = 0;
    var k_inc = 0.01;
    var curr_cl = 0;
    while (curr_cl < cl) {
      k_i = k;
      k += k_inc;
      // Integrate the t student curve to until get desired confidence level
      curr_cl += trapezoidal(
        function(t){
          return(tdist(v,t));
        }, k_i, k, 0.01) * 2; // * 2 to get both sides
    }
    return(k);
  }

  // Create a matrix of zeros
  function zero_matrix(cols, rows){
    var matrix;
    matrix = Array.apply(void 0, Array(cols)).map(
      function(){
        return(new Float32Array(rows));
      });
    return(matrix);
  }

  // Create a array of random n number for the suplied distribution and arguments (requies jStat)
  function rand_array(n, pdf, args){
    var arr = [].slice.apply(new Float64Array(n));
    var samples = arr.map(function(_){
      return pdf.sample.apply(void 0, args);
    })
    return samples;
  }

  // Use richardon extrapolation: http://en.wikipedia.org/wiki/Richardson_extrapolation
  // to compute odf
  var richardson_ode_solver = function (f, x, opts) {
    if (opts.tolerance === "undefined") {
      opts.tolerance = 0.00000001;
    }
    if (opts.max_rows === "undefined") {
      opts.max_rows = 20;
    }
    var h_offset = 0.0001; // For cases that x = 0, so the algorithm will not fail
    var t_start = -x*2;
    var err = Infinity;
    var initial_h = Math.abs(x - t_start);
    var h = initial_h + h_offset;
    var A = zero_matrix(opts.max_rows, opts.max_rows);
    for (var i = 0; i <= opts.max_rows-1; i++) {
      A[i][0] = f(x + h) - f(x - h);
      A[i][0] = A[i][0] / (2 * h);
      if (i > 0) {
        for(var j = 1; j <= i; j++) {
          A[i][j] = A[i][j-1] + (A[i][j-1] - A[i-1][j-1]) / (Math.pow(4,j-1));
        };
        err = Math.abs(A[i][i] - A[i-1][i-1]);
        if (err < opts.tolerance) {
          return(A[i][i]);
        }
      }
      h = h/2;
    };
    return(A[opts.max_rows-1][opts.max_rows-1])
  }

  // Welch-Satterthwaite effective degrees of freedom
  var w_s = function(ci_ui, df, uc) {
    
    var divisor_array = [];
    divisor_array = ci_ui.map(function(_, i){
      return ( Math.pow(ci_ui[i], 4) / df[i] );
    })

    var divisor = sum(divisor_array)

    return (Math.pow(uc, 4) / divisor);
  }

  // string is returned if math model is single line, and object with entries property if multiline
  var math_res = function(fun, scope){
    var res = fun.eval(scope);
    return typeof res === "number" ? res : res.entries[res.entries.length];
  }

  var Xfunc = function(func, math_scope, target_var_name){
    var that = this;
    this.func = func;
    this.math_scope = math_scope;
    this.target_var_name = target_var_name;

    // define math function
    this.math_func = Function;
    if(typeof this.func === "string"){
      // use mathjs lib to compile the string
      this.math_func = math.compile(this.func);
    }

    // run a iteration of function
    this.iterate = function(x){
      var scope_updt = {};
      var arg_type = typeof x;
      // If a object is passed, use it as scope
      if(arg_type === "object"){
        scope_updt = Object.create(x);
      }else{
        scope_updt = Object.create(that.math_scope);
      }
      // Accept numeric or string arguments. Strings can be accepted because 
      // they can contain informations such as complex numbers to be parsed 
      // on mathjs, but this was not tested.
      if ((arg_type === "number") || (arg_type === "string")){
        scope_updt[that.target_var_name] = x;
      }
      if(typeof that.func === "string"){
        return math_res(that.math_func, scope_updt);
      }else{
        return(that.func.call(void 0, scope_updt));
      }
    }
  }

  // create a array of size n repeating val
  var rep = function(val, n){
    var out = [];
    for (var i = n - 1; i >= 0; i--) {
      if(typeof val === "object"){
        // If its a object, return a new one, without passing the iriginal as referenca
        out.push(Object.create(val));
      }else{
        out.push(val);
      }
    };
    return out;
  }


  // create a array of size n repeating val
  var rep2 = function(val, n){
    var that = this;
    this.val = val;

    this.build_obj_item = function(){
      return Object.create(that.val);
    }
    this.build_val_item = function(){
      return that.val;
    }

    if(typeof this.val === "object"){
      this.build_item = this.build_obj_item;
    }else{
      this.build_item = this.build_val_item;
    }


    var arr = [].slice.apply(new Float64Array(n));
    this.arr = arr;

    return this.arr.map(function(){
      that.build_item(that.val);
    })
  }

  // Probability distributions
  var distributions = {
    "arcsine": Math.sqrt(2),
    "uniform": Math.sqrt(3),
    "normal": Math.sqrt(4),
    "triangular": Math.sqrt(6)
  }

  var get_distribution_div = function(val){
    var dist_val = distributions[val];
    if(dist_val === undefined){
      return(parseFloat(val));
    }else{
      return(dist_val);
    }
  }

  get_prefix = function(k) {
    var k_val, prefixes;
    prefixes = {
      "Y": 1000000000000000000000000,
      "Z": 1000000000000000000000,
      "E": 1000000000000000000,
      "P": 1000000000000000,
      "T": 1000000000000,
      "G": 1000000000,
      "M": 1000000,
      "k": 1000,
      "h": 100,
      "da": 10,
      "d": 0.1,
      "c": 0.01,
      "m": 0.001,
      "u": 0.000001,
      "n": 0.000000001,
      "p": 0.000000000001,
      "f": 0.000000000000001,
      "a": 0.000000000000000001,
      "z": 0.000000000000000000001,
      "y": 0.000000000000000000000001
    };
    return k_val = (prefixes[k] === void 0 ? 1 : prefixes[k]);
  };

  var build_scope = function(v){
    var mean_value = 0;
    var prefix = get_prefix(v.prefix)
    // copy the quantity of var
    var readout = v.value;
    if (typeof readout === "number"){
      mean_value = readout;
    }
    if (typeof readout === "string"){
      // If value is a string, split to convert csv or limited by \n to array of numbers
      readout = readout.split(/[\n,;]+/).map(function(readout){
        return parseFloat(readout);
      });
    }
    if (typeof readout === "object"){
      console.log(readout);
      var n = readout.length;
      // Case n is 0 or 1, it will be a array with only none or one value,
      // so in this case, set readout as only one numeric value
      if(n === 0){
        mean_value = 0;
      }else if (n === 1){
        mean_value = parseFloat(readout[0]) * prefix;
      }else{
        mean_value = (sum(readout)/n);

        // The array contain multiple values, 
        // so add type A uncertanty
        var values_sd = sd(readout, mean_value) * prefix;
        // Create a new uncertanty item
        var unc = {
          "name": "Repeatability",
          "value": values_sd,
          "type": "A",
          "distribution": "normal",
          "df": n - 1,
          "k": 2
        }
        // Add uncertanty relative to desviation of values
        this.uncertainties.push(unc);
        // repeat var name to array
        this.uncertainties_var_names.push(v.name);
      }
    }
    this._scope[v.name] = mean_value * prefix + v.correction;
  }

  var type_b_uncertainties = function(v){
    var that = this;
    // create reference to uncertanties
    v.uncertainties.map(function(u){
      var unc = {
        "name": u.name,
        "value": u.value,
        "type": "B",
        "distribution": u.distribution,
        "df": u.df,
        "k": u.k
      }
      that.uncertainties.push(unc);
      // Init correction
      if (v.correction === undefined){
        v.correction = 0;
      }
      // Increment correction
      if (typeof u.correction === "number"){
        v.correction += u.correction;
      }
    });
    // Create the flat version of var_names repeating the name, uncertainties.length times
    this.uncertainties_var_names = this.uncertainties_var_names.concat( [], rep(v.name, v.uncertainties.length) );
  }

  var determine_sensitive_coefficients = function(v){
    this._xfunc.target_var_name = v.name;
    var ci = richardson_ode_solver(this._xfunc.iterate, this._scope[v.name], {'tolerance': 1e-9, 'max_rows': 10});
    if(ci === undefined){
      ci = 1;
    }
    this._variables_ci_obj[v.name] = Math.abs(ci);
  }

  // Set monte carlo inputs simulations, binded to main mc scope
  var mc_simulations = function(u, i){
    var that = this;
    var args = [];
    this.var_name = that.uncertainties_var_names[i];
    var val = that.mc._scope[i][that.var_name];
    var effective_dist = u.distribution
    if(u.distribution === "uniform"){
      args = [-u.value, u.value];
    }else if(u.distribution === "triangular"){
      args = [-u.value, 0, u.value];
    }else if(u.distribution === "studentt"){
      args = [u.df];
    }else if(u.distribution === "beta"){
      args = [u.alpha, u.beta];
    }else if(u.distribution === "arcsine"){
      // Arcsine is a specific case of beta distribution
      effective_dist = "beta";
      args = [-0.5, 0.5];
    }else{ 
      args = [0, u.value]; // Arguments for normal distribution
    }
    var pdf = jStat[effective_dist];
    this.samples = rand_array(that.mc.M, pdf, args);
    // Sum samples to expectation/modified expectation
    // and update scope value for the iteration
    that.mc._scope.map(function(_, j){
      that.mc._scope[j][that.var_name] += that.samples[j];
      return void 0;
    });
  }

  // taken from http://stackoverflow.com/questions/26941168/javascript-interpolate-an-array-of-numbers
  function interpolateArray(data, fitCount) {

      var linearInterpolate = function (before, after, atPoint) {
          return before + (after - before) * atPoint;
      };

      var newData = new Array();
      var springFactor = new Number((data.length - 1) / (fitCount - 1));
      newData[0] = data[0]; // for new allocation
      for ( var i = 1; i < fitCount - 1; i++) {
          var tmp = i * springFactor;
          var before = new Number(Math.floor(tmp)).toFixed();
          var after = new Number(Math.ceil(tmp)).toFixed();
          var atPoint = tmp - before;
          newData[i] = linearInterpolate(data[before], data[after], atPoint);
      }
      newData[fitCount - 1] = data[data.length - 1]; // for new allocation
      return newData;
  };

  // javascript version of Matlab linspace
  var linspace = function(start, end, n){
    return interpolateArray([start, end], n);
  }

  // Determine The shortest coverage interval
  // JCGM 101:2008, item D.7
  var sci = function(values, alpha){
    /*
    Translated from: http://blogs.datall-analyse.nl/#post26
    #function for calculating the shortest coverage interval
    sci <- function (values, alpha=.05){
    sortedSim <- sort(values)
    nsim <- length(values)
    covInt <- sapply( 1:(nsim-round((1-alpha)*nsim) ), function(i) {
    sortedSim[1+round((1-alpha)*nsim)+(i-1)]-sortedSim[1+(i-1)]})
    lcl <- sortedSim[which(covInt==min(covInt))]
    ucl <- sortedSim[1+round((1-alpha)*nsim)+(which(covInt==min(covInt))-1)]
    c(lcl, ucl)
    }
    */
    var M = values.length;
    this.alpha = alpha === undefined ? 0.05 : alpha;
    var cov_interv = values.slice(0,M-Math.round((1-this.alpha)*M)).map(function(_, i) {
      return values[Math.round((1-this.alpha)*M)+i]-values[i];
    })
    var lower_cl = values[cov_interv.indexOf(Math.min.apply(void 0, cov_interv))];
    var upper_cl = values[Math.round((1-this.alpha)*M)+(cov_interv.indexOf(Math.min.apply(void 0, cov_interv))-1)];
    return [lower_cl, upper_cl, cov_interv];
  }

  var GUM = function(obj){
    var that = this;
    if (typeof obj === "object"){
      //this.obj = JSON.parse(JSON.stringify(obj)); // Copy obj data and avoid reference the original one
      this.obj = obj; // Copy obj data and avoid reference the original one
    }else if(typeof obj === "string"){
      this.obj = JSON.parse(obj);
    }else{
      console.error("Invalid argument.")
    }
    // Unpack uncertainties, var names and correponsing values
    this.uncertainties = [];
    this.uncertainties_var_names = []; // VI, VC, VC

    // Object scope
    this._scope = {};

    // Handle type B uncertanties, appending each uncertanty var name to uncertainties_var_names
    this.obj.variables.map(type_b_uncertainties.bind(this));
    
    // define scope values and handle type A uncertanties
    obj.variables.map(build_scope.bind(this));

    // Add influence quantities to scope, if exists
    if(obj.influence_quantities !== undefined){
      obj.influence_quantities.map(build_scope.bind(this));
    }
    

    // Create an Xfunc, that contains the math model scoped with variables quantities
    this._xfunc = new Xfunc(this.obj.func, this._scope, "");
    
    // Sensitive coefficients object
    this._variables_ci_obj = {};
    this.obj.variables.map(determine_sensitive_coefficients.bind(this));

    // Sensitive coefficients with the same 
    // size of uncertainties array and other related arrays
    this.ci = this.uncertainties_var_names.map(function(v){
      return(that._variables_ci_obj[v]);
    })


    // Standard Uncertainties
    this.ui = this.uncertainties.map(function(u, i){
      // Determine the divisor to unexpand the uncertanty
      var div;
      if(u.k !== undefined){
        div = u.k;
      }else if(u.distribution === "normal"){// Case of already unexpanded normal dist
        div = 1;
      }else if(u.distribution === "studentt"){
        div = invt(u.df, u.ci);
      }else{
        div = get_distribution_div(u.distribution);
      }
      // return standard uncertanty
      return(u.value / div);
    })

    // ci_ui
    this.ci_ui = this.uncertainties.map(function(_, i){
      return(that.ui[i] * that.ci[i]);
    })

    // contributions
    this._ci_ui_pow_2 = this.ci_ui.map(function(u){
      return(Math.pow(u, 2));
    })

    // combined uncertainty uc
    this.uc = Math.sqrt(sum(this._ci_ui_pow_2));

    // degrees of freedom
    this.df = this.uncertainties.map(function(u, i){
      // If deg of freedon was not defined, return Infinity
      return u.df === undefined ? 9999 : parseFloat(u.df);
    })

    // Effective degrees of freedom
    this.veff = w_s(this.ci_ui, this.df, this.uc);

    // compute coverage factor
    this.k = invt(this.veff, obj.cl)

    // expanded uncertainty
    this.U = this.uc*this.k;

    // Output
    this.y = this._xfunc.iterate();

    // UNDER DEVELOPMENT
    // Monte Carlo
    // 

    if(this.obj.method === "mc"){
      this.mc = {};
      this.mc.M = 10000;
      // Create MC scope, repeating the expectation values from GUM framework scope
      this.mc._scope = rep(this._scope, this.mc.M);
      // MC distributions inputs simulations
      this.uncertainties.map(mc_simulations.bind(this));

      
      /*this.obj.variables.map(function(v){
        var that = this;
        console.log(v.name + " average, max, min: ")
        var sum = 0;
        var arr = [];
        for (var i = that.mc._scope.length - 1; i >= 0; i--) {
          sum += that.mc._scope[i][v.name];
          arr.push(that.mc._scope[i][v.name]);
        };
        console.log(sum/that.mc._scope.length);
        console.log( Math.max.apply(void 0, arr) );
        console.log( Math.min.apply(void 0, arr) );
        console.log( jStat.histogram(arr, 50).toString().replace(/,/g, "\n") );
      }.bind(this))*/

      // Compute simulations for model
      console.log("Computing...");
      this.mc._iterations = [];
      for (var i = this.mc.M - 1; i >= 0; i--) {
        this.mc._iterations.push(this._xfunc.iterate(this.mc._scope[i]));
      };
      console.log("Finish!");
      // Sort iterations
      this.mc._iterations.sort(function sortNumber(a,b){return a - b});
      // Mean value
      this.mc._iterations_mean = sum(this.mc._iterations) / this.mc.M;
      // Compute a histogram
      this.mc.histogram = jStat.histogram(this.mc._iterations, 100);
      // ref: 7.6 Estimate of the output quantity and the associated standard uncertainty CGM_101_2008_E.pdf
      this.mc.uc = Math.sqrt(jStat.sumsqrd( inc_arr(this.mc._iterations, this.mc._iterations_mean)) * (1/(this.mc.M-1)));
      // ref: 7.7 Coverage interval for the output quantity
      this.mc.p = (1 - this.obj.cl);
      // The shortest coverage interval
      this.mc.sci_limits = sci(this.mc._iterations, this.mc.p);
    }
    return(void 0);
  }
  window.GUM = GUM;
})();