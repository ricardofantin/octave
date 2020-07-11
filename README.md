# Octave
I put my initial octave functions here. When they are ready, they will be submitted to octave.

Some papers used in the implementation are here too. No copyright infringement intended, they are easy to find on internet. If you have any problem, please ask me and I will remove it.

Working on:

* multithresh/ . Submitted, but need a major review. [patch](https://savannah.gnu.org/patch/?9602) .
* corner/ function. Main function corner.m and have two papers: Harris.pdf and ShiTomasi.pdf
* <del>structural element diamond shape decomposition</del> <ins>octave does not benefits from this decomposition</ins>. Using file get\_diamond\_template.m mainly. Other files are: testSpeed.m, template-diamond.pdf and the imglib2-algorithm package [https://github.com/tinevez/imglib2-algorithm](https://github.com/tinevez/imglib2-algorithm)
* angl2str . Submitted, but was already in upcoming mapping 1.4.1. My version is entire compatible with Mablab. [patch](https://savannah.gnu.org/patch/?9953).
* <del>str2angle</del> submitted in 1.4.1, but revision and test was asked.

Accepted:

* colorangle.m

Easy functions to me, I'll work on them in the future:

* dist2d
* <del>imfuse</del> already submitted [patch](https://savannah.gnu.org/patch/?9730)
* improfile
* visboundaries
