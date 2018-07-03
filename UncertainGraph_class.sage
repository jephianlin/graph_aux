### for _circle_embedding
from sage.graphs.graph_plot import _circle_embedding

class UncertainGraph:
    """
    A graph data structure where edges are categorized 
    into three parts: edges, nonedges, and uncertain;
    To input a UncertainGraph, use UncertainGraph(ge,gn);
    Here ge.vertices()==gn.vertices, ge.edges() are the edges, and gn.edges() are the nonedges;
    """ 
    
    def __init__(self,ge,gn):
        if ge.vertices()!=gn.vertices():
            raise ValueError("ge and gn should be on the same vertex set");
        gu=ge.union(gn);
        if gu.size()!=ge.size()+gn.size():
            raise ValueError("edges of ge and gn should not overlap");
        self.ge=ge.copy();
        self.gn=gn.copy();
        self.gu=gu; # gu is the union but not the uncertain graph!
        self.pos=ge.get_pos();

    def update_gunion(self):
        self.gu=self.ge.union(self.gn);

    def vertices(self,**kwargs):
        return self.ge.vertices(**kwargs);

    def order(self):
        return self.ge.order();
        
    def get_pos(self):
        return self.pos;
        
    def set_pos(self,pos):
        self.pos=pos;
        
    def edges(self,**kwargs):
        return self.ge.edges(**kwargs);
        
    def nonedges(self,**kwargs):
        return self.gn.edges(**kwargs);
        
    def uncertain_edges(self,**kwargs):
        return self.gu.complement().edges(**kwargs);
    
    def add_vertex(self,v):
        self.ge.add_vertex(v);
        self.gn.add_vertex(v);
        self.update_gunion();
    
    def add_edge(self,i,j):
        self.ge.add_edge(i,j);
        if self.gn.has_edge(i,j):
            self.gn.delete_edge(i,j);
        self.update_gunion();
            
    def add_nonedge(self,i,j):
        self.gn.add_edge(i,j);
        if self.ge.has_edge(i,j):
            self.ge.delete_edge(i,j);
        self.update_gunion();
               
    def make_uncertain(self,i,j):
        if self.ge.has_edge(i,j):
            self.ge.delete_edge(i,j);
        if self.gn.has_edge(i,j):
            self.gn.delete_edge(i,j);
        self.update_gunion();
        
    def show(self,**kwargs):
        if "pos" not in kwargs.keys():
            new_pos=self.pos;
            if new_pos==None:
                _circle_embedding(self.ge,self.ge.vertices());
                new_pos=self.ge.get_pos();
        else:
            kwargs.pop("pos");
        from sage.graphs.graph_plot import graphplot_options
        plot_kwds = {k:kwargs.pop(k) for k in graphplot_options if k in kwargs}
        ge_draw=self.ge.graphplot(pos=new_pos,**plot_kwds).plot(**kwargs);
        gn_draw=self.gn.graphplot(pos=new_pos,edge_style="dashed",**plot_kwds).plot(**kwargs);
        gu_draw=self.gu.complement().graphplot(pos=new_pos,edge_color="gray",**plot_kwds).plot(**kwargs);
        pic=gu_draw+ge_draw+gn_draw;
        pic.show(axes=False);

    def neighborhood_matrix(self):
    	return self.ge.adjacency_matrix()+identity_matrix(self.ge.order())-2*self.gu.complement().adjacency_matrix();

    def adjacency_matrix(self):
    	return self.ge.adjacency_matrix()-2*self.gu.complement().adjacency_matrix();
    
    def copy(self):
        g=UncertainGraph(self.ge,self.gn);
	g.set_pos(self.pos);
	return g;
