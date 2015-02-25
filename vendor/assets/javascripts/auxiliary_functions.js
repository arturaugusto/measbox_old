// cross plataform indexOf
// ref: http://stackoverflow.com/questions/1181575/javascript-determine-whether-an-array-contains-a-value
var indexOf = function(needle) {
		if(typeof Array.prototype.indexOf === 'function') {
				indexOf = Array.prototype.indexOf;
		} else {
				indexOf = function(needle) {
						var i = -1, index = -1;

						for(i = 0; i < this.length; i++) {
								if(this[i] === needle) {
										index = i;
										break;
								}
						}

						return index;
				};
		}

		return indexOf.call(this, needle);
};

var do_uut_lookup;

do_uut_lookup = function(temp_data) {
	var UUT_ranges, selector, uut_name, uut_prefixes, uut_units;
	uut_name = _.filter(temp_data.value.variables, function(v) {
		return v.kind.toString() === "UUT";
	})[0].name.toString();
	selector = _.filter(temp_data.lookup, function(v) {
		return v["var"].toString() === uut_name;
	}).map(function(s) {
		return {
			snippet_i: s.snippet_index,
			range_i: s.range_index
		};
	});
	uut_ids = selector.map(function(s) {
		return temp_data.asset_snippets.snippets[s.snippet_i].asset_id
	});
	UUT_ranges = selector.map(function(s) {
		return temp_data.asset_snippets.snippets[s.snippet_i].value.ranges[s.range_i];
	});
	uut_units = UUT_ranges.map(function(r) {
		return r.unit;
	});
	uut_prefixes = UUT_ranges.map(function(r) {
		return r.prefix;
	});
	return {
		uut_ids: uut_ids,
		uut_name: uut_name,
		uut_units: uut_units,
		uut_prefixes: uut_prefixes
	};
};
