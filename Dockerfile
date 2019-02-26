FROM ubuntu:latest

LABEL maintainer="ouranoshong <ouranoshong@outlook.com>"

ENV UNAME=developer
ENV UHOME=/home/${UNAME}
ENV UWORKSPACE=${UHOME}/workspace
ENV TZ=Asia/Shanghai
ENV LANG="en_US.UTF-8"

#http://mirrors.cn99.com
#mirrors.aliyun.com
#mirrors.tuna.tsinghua.edu.cn
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -yq upgrade \
    && apt-get -yq install locales tzdata sudo apt-utils build-essential language-pack-zh-hans cmake exuberant-ctags ccache tmux \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get -yq install git curl wget  \
    && apt-get -yq build-dep vim \
    && git clone https://github.com/vim/vim.git \
    && cd vim \
    && make distclean \
    && export PREFIX='/usr/local' \
    && ./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-python3interp \
            --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-cscope \
            --enable-gui=auto \
            --enable-gtk2-check \
            --with-x \
            --with-compiledby="j.jith" \
            --prefix=$PREFIX \
    && make && make install \
    && sh -c "update-alternatives --install /usr/bin/editor editor $PREFIX/bin/vim 1; \
        update-alternatives --set editor $PREFIX/bin/vim; \
        update-alternatives --install /usr/bin/vim vim $PREFIX/bin/vim 1; \
        update-alternatives --set vim $PREFIX/bin/vim; \
        update-alternatives --install /usr/bin/vi vi $PREFIX/bin/vim 1; \
        update-alternatives --set vi $PREFIX/bin/vim; \
        update-alternatives --install /usr/bin/gvim gvim $PREFIX/bin/gvim 1; \
        update-alternatives --set gvim $PREFIX/bin/gvim" \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/deb-src/# deb-src/g' /etc/apt/sources.list


RUN useradd -ms /bin/bash ${UNAME} && \
    echo "${UNAME}:${UNAME}" | chpasswd && \
    adduser ${UNAME} sudo && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chown -Rf ${UNAME}.${UNAME} ${UHOME}

USER ${UNAME}

RUN mkdir ${UWORKSPACE}
COPY .vimrc-vundle ${UHOME}/.vimrc-vundle

RUN cat ~/.vimrc-vundle >> ~/.vimrc \
    && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
    && vim +PluginInstall +qall \
    && cd ~/.vim/bundle/YouCompleteMe \
    && python3.6 install.py --clang-completer \
    && rm ~/.vimrc

COPY .vimrc-rc ${UHOME}/.vimrc-rc

RUN git clone https://github.com/amix/vimrc.git ${UHOME}/.vim_runtime  \
    &&  sh ~/.vim_runtime/install_awesome_vimrc.sh \
    && cat ${UHOME}/.vimrc-vundle  >> ~/.vimrc \
    && cat ${UHOME}/.vimrc-rc  >> ~/.vimrc

WORKDIR ${UWORKSPACE}

CMD [ "tmux" ]