import * as types from '../mutation-types';

//State for one grid
function gridStateFactory(){
    return {
        results: [], //The search results
        currentPage: 1, //The current page
        resultsPerPage: 10, //How many results are shown per page
        numResults: 0, //The total amount of results for the current query
        sortCrits: [], //Sort criterias
        facets: []
    };
}

// Initial state for the grid module
const INITIAL_STATE = {
    gridStates: [] //Contains the grid states of all grids
};

const actions = {
    addGridState ({commit, state}, {callback}){
        let newGridState = gridStateFactory();
        commit(types.ADD_GRID_STATE, {newGridState});
        callback(newGridState);
    }
}

// Mutations
const mutations = {
    [types.ADD_GRID_STATE] (state, {newGridState}) {
        state.gridStates.push(newGridState);
    },
    [types.SET_CURRENT_PAGE] (state, {gridState, page}) {
        gridState.currentPage = page;
    },
    [types.CHANGE_SORT] (state, {gridState, sortCrits}) {
        gridState.sortCrits = sortCrits;
    },
    [types.SET_RESULTS] (state, {gridState, results}) {
        gridState.results = results;
    },
    [types.SET_RESULTS_PER_PAGE] (state, {gridState, resultsPerPage}) {
        gridState.resultsPerPage = resultsPerPage;
    },
    [types.SET_NUM_RESULTS] (state, {gridState, numResults}) {
        gridState.numResults = numResults;
    },
    [types.REGISTER_FACET] (state, {gridState, facet}) {
        gridState.facets.push(facet);
    },
}

export default {
    namespaced: true,
    state: INITIAL_STATE,
    actions,
    mutations
};
