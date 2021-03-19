% method not perfect right now. Basically, I take the average of all the
% non-zero neighbors surrounding each value that is zero. If a particular
% value itself is surrounded by at least one zero, it's value is the
% average of the non-zero neighbors

function filledMap = fillZeroEntries(map)

filledMap = map;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        if map(i,j) == 0
           if i == 1
               startind = 1;
               endind = i+1;
           elseif i == size(map,1)
               startind = i-1;
               endind = i;
           else
               startind = i-1;
               endind = i+1;
           end
           
           if j == 1
               startjnd = 1;
               endjnd = j+1;
           elseif j == size(map,2)
               startjnd = j-1;
               endjnd = j;
           else
               startjnd = j-1;
               endjnd = j+1;
           end
               
           neighbors = map(startind:endind,startjnd:endjnd);
           neighbors = reshape(neighbors,[],1);
           nonzeroI = neighbors > 0;
           if sum(nonzeroI > 0)
               filledMap(i,j) = mean(neighbors(nonzeroI));
           end
           
        end
        
    end
end

end