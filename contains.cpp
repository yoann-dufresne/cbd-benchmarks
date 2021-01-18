//
// Created by alexa on 29/10/2020.
//

#include <cstdlib>
#include <string>
#include <iostream>
#include <istream>
#include <fstream>
#include <random>
#include <chrono>
#include "ConwayBromageLib.h"
#include <lest/lest_basic.hpp>
#include <vector>
#include <bitset>
#include <sdsl/sd_vector.hpp>
#include <sdsl/vectors.hpp>
#include <cmath>
#include <future>

using namespace std;
using namespace sdsl;
using namespace lest;
using namespace std::chrono;

// k-mer size : always 31 mers
#define SIZE 31

/**
* Returns a list of k-mers contained in a query file.
* @param fastqFilePath - query file
* @param KmerSize - size of cut sequences
*/
vector<uint64_t> getKmersFromQueryFile(string fastqFilePath, KmerManipulator *km){
    vector<uint64_t> res;
    int KmerSize = km->getSize();
    ifstream fi(fastqFilePath, ios::in);

    string kmer_str;
    //sequences are in lineNumber = 2*k with k an integer
    while(getline(fi, kmer_str)){ //we ignore lines containing ">kmer"
        getline(fi, kmer_str);    //takes the kmer
        res.push_back(km->encode(kmer_str));
    }

    fi.close();
    cout << "K-mers obtained in vector from : " << fastqFilePath << endl;
    return res;
}

double run(string query, const ConwayBromage &cb){
    ifstream fi(query);
    KmerManipulatorACTG km30(30);
    vector<uint64_t> v = getKmersFromQueryFile(query, &km30);
    fi.close();

    auto a = chrono::high_resolution_clock::now();
    uint64_t len = v.size();
    //cout << "vector's size : " << len << endl;
    for(int i = 0; i < len; i++){
        cb.contains(v[i]);
    }
    auto b = chrono::high_resolution_clock::now();
    double elapsed = chrono::duration_cast<chrono::microseconds>(b-a).count();
    cout << "run time : " << elapsed << "s for : " << query << endl;
    return elapsed;
}
/*
 * params[0] : fichier de test
 * params[1] : écriture des résultats pour temps de query
 * params[2] : écriture des résultats pour temps de builds
 * */
int main(int n, char *params[]){
    //k-mer file reading
    ifstream file(params[1], ios::in);
    /*for(int i = 0 ; i < n ; i++){
        cout << params[i] << endl;
    }*/
    cout << "Nombre de parametre d'entrees : " << n << endl;
    ofstream outBuildTime(params[4], ios::app);
    //définition gestionnaire de k-mers
    KmerManipulatorACTG km_ecoli(SIZE);
    //création de l'objet et mesure du temps
    auto a = chrono::high_resolution_clock::now();
    ConwayBromage cb_ecoli (file, &km_ecoli);
    auto b = chrono::high_resolution_clock::now();
    double elapsed = chrono::duration_cast<chrono::milliseconds>(b-a).count();
    cout << "temps pour build ecoli : " << elapsed << " millisecondes" << endl;
    outBuildTime << elapsed << endl;
    outBuildTime.close();

    //requête et mesure du temps
    ofstream outQuery(params[3], ios::app);
    double ret = run(params[2], cb_ecoli);
    cout << "temps pour requête : " << ret << " microsecondes" << endl;
    outQuery << ret << endl;
    outQuery.close();
    return 0;
}
