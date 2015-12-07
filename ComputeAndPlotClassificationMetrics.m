rootdir = '.';


%% N x 1 cell string
%Id = {};
%fid = fopen(sprintf('%s/features_rb_4Dec2015_x.txt', rootdir));
%  s=fgetl(fid); while ischar(s), Id{end+1}=s, s=fgetl(fid), end
%fclose(fid);
% N x 1 double
Y = dlmread(sprintf('%s/features_rb_4Dec2015_y.txt', rootdir));
pmask = Y>.5;
nmask = ~pmask;

npos=sum(pmask);
nneg=sum(nmask);

fprintf('Feature statistics:\n');
fprintf('%d positive examples.\n%d negative examples.\n', npos, nneg);
if npos > nneg
  fprintf('positive majority at %0.2f : 1 ratio.\n', npos/nneg);
else
  fprintf('negative majority at %0.2f : 1 ratio.\n', nneg/npos);
end
fprintf('\n');


% raw scores and models
% M x 1 cell string
model_names = {};
fid=fopen(sprintf('%s/features_rb_4Dec2015_problem.ser_classifiers_names.txt', rootdir));
  s=fgetl(fid); while ischar(s), model_names{end+1}=s, s=fgetl(fid), end
fclose(fid);
% N X M double
Pr = dlmread(sprintf('%s/features_rb_4Dec2015_problem.ser_classifiers_scores.txt', rootdir));


%figure(1);  % comparing positives
%hold on;
%clear h;
%h(1) = plot(1:npos, Pr(pmask,1), 'r');
%h(2) = plot(1:npos, Pr(pmask,2), 'b');
%legend(model_names, h);

%figure(2);  % comparing negatives
%hold on;
%clear h;
%h(1) = plot(1:nneg, Pr(nmask,1), 'r');
%h(2) = plot(1:nneg, Pr(nmask,2), 'b');
%legend(model_names, h);


figure(3);
hold on;
clear h L;
h(1) = plot([1:npos]/npos, sort(Pr(pmask,1),'descend'), 'r-', 'linewidth', 1);
L{1} = sprintf('model 1 - fraction of +''s accepted');
h(2) = plot([1:nneg]/nneg, sort(Pr(nmask,1),'ascend'), 'r:', 'linewidth', 1);
L{2} = sprintf('model 1 - fraction of -''s rejected');
h(3) = plot([1:npos]/npos, sort(Pr(pmask,2),'descend'), 'b-', 'linewidth', 2);
L{3} = sprintf('model 2 - fraction of +''s accepted');
h(4) = plot([1:nneg]/nneg, sort(Pr(nmask,2),'ascend'), 'b:', 'linewidth', 2);
L{4} = sprintf('model 2 - fraction of -''s rejected');
xlabel('fraction of +''s accepted or -''s rejected')
ylabel('threshold')
title('accept/reject rates');
h=legend(L,h,'location','west');
set(h,'FontSize',10);
axis equal;



figure(4);
hold on;
Th=[0:.1:1];
for t=1:length(Th)
  % recall
  pr1(t,1) = sum(Pr(pmask,1) > Th(t)) / npos;
  pr2(t,1) = sum(Pr(pmask,2) > Th(t)) / npos;
  
  % other
  pr1(t,2) = sum(Pr(nmask,1) < Th(t)) / nneg;
  pr2(t,2) = sum(Pr(nmask,2) < Th(t)) / nneg;
  
  % precision
  pr1(t,3) = sum(Pr(pmask,1) > Th(t)) / sum(Pr(:,1) > Th(t));
  pr2(t,3) = sum(Pr(pmask,2) > Th(t)) / sum(Pr(:,2) > Th(t));
end
clear h L;
h(1)=plot(pr1(:,1), pr1(:,3), 'ro-', 'linewidth', 3);
L{1}='model 1 '
h(2)=plot(pr2(:,1), pr2(:,3), 'bo-', 'linewidth', 3);
L{2}='model 2 '
xlabel('recall');
ylabel('precision');
title('precision-recall');
h=legend(L,h,'location','southwest');
set(h,'FontSize',10);
axis equal;


dx=-.08;
dy=-.02;
for t=2:2:size(pr1,1)
  text(pr1(t,1)+dx,pr1(t,3)+dy, sprintf('t=%.2f',Th(t)));
end

for t=2:2:size(pr2,1)
  text(pr2(t,1)+dx,pr2(t,3)+dy, sprintf('t=%.2f',Th(t)));
end
plot([0,1],[0,1],'k-');
axis equal;
%h0 = legend(model_names, h);
%legend(h0, 'location', 'southwest');
%set(h0, 'FontSize', 20);
